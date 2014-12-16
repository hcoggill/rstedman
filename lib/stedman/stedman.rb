
module Stedman

  VERSION = '1.0.0'

  QUICK = 0
  SLOW = 1
  PLAIN = 0
  BOB = 1
  SINGLE = 2
  HAND = 1
  BACK = 2

class CompParser

  attr_reader :comp, :courses

  def initialize(num_bells)
    @n = num_bells
    @comp = []
    @courses = []
  end

  def comp_string(comp, courses)
    @comp = comp
    @courses = courses
    i = 0
    str = []
    courses.each do |course_len|
      this_course = []
      this_str = ""
      course_len.times do |six|
        calling = comp[i]
        this_course << "#{six + 1}" if calling == BOB
        this_course << "s#{six + 1}" if calling == SINGLE
        i += 1
      end
      this_str << this_course.join('.')
      if course_len != 22 or this_course.length == 0
        this_str << " (#{course_len})"
      end
      str << this_str
    end
    str.join("\n")
  end

  def parse(str)
    # assume lines are a course
    # calls are separated, e.g. 1, 3, s4 s6 s9
    # non-standard course length needs to be in brackets, e.g. 1, 19 (23)
    # named blocks need to be in square brackets, can extend more than 1 course...
    #  e.g. 1, 3, 20 [AA]	# means this and previous course are "A"
    comp_history = []
    named_blocks = {}
    named_blocks_courses = {}
    str.each_line do |line|
      #puts "Testing #{line}"
      tokens = line.split(/[\s,.]+/)
      if tokens.first =~ /^[a-rt-zA-Z]/
        # this is a named block
        #puts "Have named block: #{tokens.first}"
        named_blocks[tokens.first].each do |blk|
          #puts "Adding #{blk}"
          @comp << blk
        end
        named_blocks_courses[tokens.first].each do |cl|
          @courses << cl
        end
        #puts "Added named course, len #{named_blocks[tokens.first].length}"
        next
      end

      course_len = @n * 2
      calls = {}
      calls[:bob] = []
      calls[:single] = []
      block_name = nil
      
      tokens.each do |symbol|
        next if symbol.length == 0
        call = nil
        call_nums = nil
        if symbol =~ /\((\d+)\)/
          #puts "Got course length #{$1}"
          course_len = $1.to_i
          next
        elsif symbol =~ /\[(.*)\]/
          #puts "Got named block: #{$1}"
          block_name = $1.chars.first
          next
        elsif symbol =~ /^(\d.*)s/
          call_type = :single
          call_nums = $1
        elsif symbol =~ /^s(\d.*)/
          call_type = :single
          call_nums = $1
        elsif symbol =~ /^(\d.*)/
          call_type = :bob
          call_nums = $1
        else
          puts "Unknown token: #{symbol} (#{symbol.length})"
          next
        end
        next if call_type.nil? or call_nums.nil?
        #puts "Call type #{call_type}, rep #{call_nums}"
        call_first, call_last = call_nums.split('-')
        if call_last.nil?
          calls[call_type] << call_nums.to_i - 1
        else
          (call_first.to_i..call_last.to_i).each do |i|
            calls[call_type] << i - 1
          end
        end       
      end	# end symbol parsing

      # Now we need to construct the course
      course = []
      course_len.times do |i|
        if calls[:bob].include? i
          course << BOB
        elsif calls[:single].include? i
          course << SINGLE
        else
          course << PLAIN
        end
      end
      #puts "Have course: #{course}"
      comp_history << course

      unless block_name.nil?
        block_index = comp_history.size - $1.length
        named_blocks[block_name] = []
        named_blocks_courses[block_name] = []
        while block_index < comp_history.size
          #puts "Named block #{block_index} is #{comp_history[block_index].length}"
          named_blocks_courses[block_name] << comp_history[block_index].length
          comp_history[block_index].each do |c|
            named_blocks[block_name] << c
          end
          block_index += 1
        end
      end

      course.each do |c|
        @comp << c
      end
      @courses << course.length
 
    end
    #puts "Have comp: #{@comp}"
    return @comp
  end

end


class Touch
  # Internal representations of arrays are 0-based
  
  attr_reader :row, :false_rows, :musicals, :start_stroke, :start_six, :start_offset, :comp, :courses, :magic_rows, :course_lengths, :course_offsets

  def initialize(n, start_six = QUICK, six_offset = 3)
    @rounds = Array(1..n)
    @n = n
    @start_stroke = HAND
    @start_offset = six_offset
    @start_six = start_six
    @pn = []
    @pn[QUICK] = [[0], [2], [0], [2], [0], [n - 1], [n - 3], [n - 3, n - 2, n - 1]]
    @pn[SLOW] = [[2], [0], [2], [0], [2], [n - 1], [n - 3], [n - 3, n - 2, n - 1]]
    @comp = [PLAIN] * 22
    @courses = [22]
    reset
  end

  def reset
    @false_rows = []
    @proving = {}
    @musicals = {}
    @row = @rounds
    @history = []
    @magic_rows = []
    @six = 0
    @offset = @start_offset
    @six_type = @start_six
  end

  def go
    reset
    change until finished?
    # If it didn't finish on a six-end, calculate the changes that would have come after
    # start offset = 3 / rounds is 4th row of quick six blah di blah
    # which means that we are expecting 5 - 3 more rows
    last_row = @row
    remaining = (6 - ((@history.length - (5 - @start_offset)) % 6)) % 6
    #puts "I have #{@history.length} changes, six start offset #{@start_offset}, magic changes remaining #{remaining}"
    remaining.times do |i|
      change(false)
      @magic_rows << @history.pop      
    end
    @row = last_row
    calculate_course_offsets
  end

  def is_true?
    @false_rows.empty?
  end

  # Format a readable string from an array of the composition
  def comp_string
    cp = CompParser.new(@n)
    cp.comp_string(@comp, @courses)
  end

  # Take a string representation of a touch, e.g. "1.2.3 (20)\n4.s9"
  def set_comp(comp)
    cp = CompParser.new(@n)
    @comp = cp.parse(comp)
    @courses = cp.courses
  end

  # 0-based course index
  def calculate_course_offsets
    # iterate over the previous courses to get the start offset of the course we need
    # there is a problem with counting the number of sixes in, say, the plain course:
    # are there 22 or 23 sixes, given that the first and last are incomplete?!
    # there appears to be some concensus that the "first" six is actually not counted
#    puts "Rows:"
#    offset = 4
#    six = 0
#    length = 0
#    @history.each do |r|
#      if offset == 0
#        puts "-------- #{length} rows"
#        puts "Six #{six}"
#      end
#      puts stringify r
#      offset += 1
#      length += 1
#      if offset == 6
#         offset = 0
#         six += 1
#      end
#    end


    @course_offsets = []
    @course_lengths = []
    offset = 0
    @courses.length.times do |i|
      length = @courses[i] * 6
      #puts "For course #{i}, length initially #{length}"
      if i == 0
        length -= @start_offset
        length += 5
        #puts "Adjusted to #{length} for dummy initial six"
      end
      if i == @courses.length - 1
        length -= @magic_rows.length
        #puts "Adjusted to #{length} for last six"
      end
      @course_offsets << offset
      @course_lengths << length
      #puts "Course #{i} has length #{length}, offset #{offset}"
      offset += length
    end

  end


  def course_rows(course)
    #puts "Asked for course #{course}, offset #{@course_offsets[course]}, length #{@course_lengths[course]}"
    @history[@course_offsets[course], @course_lengths[course]]
  end

  # want to be able to find the maximum course length in changes, including
  # the 0th/non-existant initial course - tough...

  # want to be able to translate between actual course row offsets
  # and the required visual index

  # want to be able to get a description for the row - course index, six num &c
  # erm, do we want to have that in this class.....? it's a bit visual.
  def visual_course_row(course, row)
    if course == 0
      stringify @history[row]
    else
      row -= (5 - @start_offset)
      if row < 0 or row >= @course_lengths[course]
        return ""
      end
      stringify @history[@course_offsets[course] + row]
    end
  end

  def num_rows
    n = @course_lengths.max
    if n != @course_lengths.first
      n += (5 - @start_offset)
    end
    n
  end

  def num_columns
    @courses.length
  end


  def course_comp(course)
    @comp[@courses[0, course].inject(:+) || 0, @courses[course]]
  end

  def set_course(course, dat)
    return if course >= courses.length
    # select the course data before, then fit in the new dat, then add the data after
    @comp = @comp[0, @courses[0, course].inject(:+) || 0] + dat + @comp[@courses[0, course + 1].inject(:+) || 0, @comp.length]
    @courses[course] = dat.length
  end

  def add_course
    @comp = @comp + [PLAIN] * @n * 2
    @courses << @n * 2
  end

  def remove_course
    @comp = @comp[0, @comp.length - @courses.last]
    @courses.pop
  end
 
  def six_ends(course = nil)
    # if start_offset == 3, i = 1
    # if start_offset == 4, i = 0
    # if start_offset == 5, i = 5
    # if start_offset == 0, i = 4
    # if start_offset == 1, i = 3
    # if start_offset == 2, i = 2
    ends = []
    if course.nil?
      rows = @history
      course = 0
    else
      rows = course_rows(course)
    end
    i = 0
    if course == 0
      i = 4 - @start_offset
      if i < 0
        i += 6
      end
    end
    while i < rows.length
      ends << rows[i]
      i += 6
    end
    ends
  end

  def call_string(six)
    s = ''
    s = '-' if comp[six] == BOB
    s = 's' if comp[six] == SINGLE
    s
  end

  def printable(row, col)
    bell_to_str(@history[row][col])
  end

  def rows
    @history
  end

  def num_bells
    @n
  end
  
  def all_bells
    return @n if @n.even?
    return @n + 1
  end

  def finished?
    #puts "finished: #{@six} / #{@comp.size}"
    return false if @six < @comp.size
    return true if @six == @comp.size and @offset == 5
    rounds?
  end
  
  def rounds?
    @row == @rounds
  end

  def change(check_truth = true)
    nrow = []
    if @offset == 5
      pn = @pn[@six_type][@offset + @comp[@six]]
      @offset = 0
      @six_type = (@six_type + 1) % 2
      @six += 1
    else
      pn = @pn[@six_type][@offset]
      @offset += 1
    end

    pos = 0
    while pos < @n do
      if pn.include?(pos)
        nrow << @row[pos]
      else
        nrow << @row[pos + 1]
        nrow << @row[pos]
        pos += 1
      end
      pos += 1
    end
    
    @history << nrow
    if check_truth and @proving[nrow]
      @false_rows << stringify(nrow)
    else
      @proving[nrow] = 1
    end
    @row = nrow
    #puts "New row: #{nrow}"
  end
  
  def stringify(row)
    s = ""
    row.each do |r|
      s << bell_to_str(r)
    end
    s
  end

  def bell_to_str r
    case r
    when 10
      '0'
    when 11
      'E'
    when 12
      'T'
    else
      r.to_s
    end
  end

end

end



