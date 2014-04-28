
module Stedman

  VERSION = '1.0.0'

  QUICK = 0
  SLOW = 1
  PLAIN = 0
  BOB = 1
  SINGLE = 2
  HAND = 1
  BACK = 2

class MusicGen

  def initialize(num_bells)
    @n = num_bells
  end

  def named_changes
    music = { Backrounds: [[backrounds, HAND + BACK]], Queens: [[queens, HAND + BACK]], Kings: [[kings, HAND + BACK]], Tittums: [[tittums, HAND + BACK]], Nearmiss: nearmisses, DoubleWhittingtons: [[doublewhittingtons, HAND + BACK]], Updown: [[updown, HAND + BACK]], HandstrokeHomes: [[homes, HAND]], BackstrokeHomes: [[homes, BACK]] }
  end

  def nearmisses
    miss_list = []
    rounds = Array(1..@n)
    (@n - 1).times do |i|
      miss_list << [swap_pair(rounds, i), HAND + BACK]
    end
    miss_list
  end

  def swap_pair(ary, offset)
    swapped = Array.new(ary)
    a = swapped[offset]
    b = swapped[offset + 1]
    swapped[offset] = b
    swapped[offset + 1] = a
    return swapped
  end

  def homes
    Array[nil] * (@n / 2.0).ceil + Array(((@n / 2.0).ceil + 1)..@n)    
  end

  def updown
    Array(1..(@n / 2.0).ceil).reverse + Array(((@n / 2.0).ceil + 1)..@n)
  end

  def backrounds
    Array(1..@n).reverse
  end

  def queens
    Array((1..@n).step(2)) + Array((2..@n).step(2))
  end

  def kings
    Array((1..@n).step(2)).reverse + Array((2..@n).step(2))
  end

  def tittums
    Array(1..(@n / 2.0).ceil).zip(Array(((@n / 2.0).ceil + 1)..@n)).flatten.compact
  end

  def doublewhittingtons
    m = (@n / 2.0).ceil
    Array((1..m).step(2)).reverse + Array((2..m).step(2)) + Array(((m + 1)..@n).step(2)).reverse + Array(((m + 2)..@n).step(2))
  end

end


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
  
  attr_reader :row, :false_rows, :musicals, :start_stroke, :start_six, :start_offset, :comp, :courses, :magic_rows

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
  def course_rows(course)
    # iterate over the previous courses to get the start offset of the course we need
    # there is a problem with counting the number of sixes in, say, the plain course:
    # are there 22 or 23 sixes, given that the first and last are incomplete?!
    # there appears to be some concensus that the "first" six is actually not counted
    offset = 0
    course.times do |i|
      offset += @courses[i] * 6
      if i == 0
        offset -= @start_offset + 1
        offset += 6
      end
    end
    length = @courses[course] * 6
    if course == 0
      length -= @start_offset + 1
      length += 6
    end
    #puts "Asked for course #{course}, offset #{offset}, length #{length}"
    @history[offset, length]
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
 
  def six_ends
    ends = []
    i = 4 - @start_offset
    while i < @history.length do
      puts "On row #{i}, which is #{@history[i]}"
      ends << stringify(@history[i])
      i += 6
    end
    if @magic_rows.size > 0
      ends << "(#{stringify @magic_rows.last})"
    end
    return ends
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

  def check_music
    m = MusicGen.new(@n)
    
    music = m.named_changes
    stroke = @start_stroke
    @history.each do |row|
      parse_music_row(music, row, stroke)
      stroke = (stroke % 2) + 1
    end
  end

  def parse_music_row(music, row, stroke)
    music.each do |name, requirements|
      requirements.each do |mus|
        next if mus.last != HAND + BACK and mus.last != stroke
        if comp_music_row(mus.first, row)
          @musicals[name] ||= 0 and @musicals[name] += 1
        end
      end
    end
  end

  def comp_music_row(a, b)
    return false unless a.length == b.length
    a.length.times do |i|
      return false if not a[i].nil? and not a[i] == b[i]
    end
    true
  end

end

end



