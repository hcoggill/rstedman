require 'pp'

# want to be able to input some calls, like 1, 3, s4, 6-11, 18; and display the
# length of the touch, the truth, the musical value, optionally the sixes, six+1s, or 
# all changes
# also want a git-style database of comps...? erm, not sure

module Stedman

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

  attr_reader :comp

  def initialize(num_bells)
    @n = num_bells
  end

  def parse(str)
    # assume lines are a course
    # calls are separated, e.g. 1, 3, s4 s6 s9
    # non-standard course length needs to be in brackets, e.g. 1, 19 (23)
    # named blocks need to be in square brackets, can extend more than 1 course...
    #  e.g. 1, 3, 20 [AA]	# means this and previous course are "A"
    @comp = []
    comp_history = []
    named_blocks = {}
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
        next
      end

      course_len = @n * 2
      calls = {}
      calls[:bob] = []
      calls[:single] = []
      block_name = nil
      
      tokens.each do |symbol|
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
        elsif symbol =~ /^s(\d.*)/
          call_type = :single
          call_nums = $1
        elsif symbol =~ /^(\d.*)/
          call_type = :bob
          call_nums = $1
        else
          puts "Unknown token: #{symbol}"
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
        while block_index < comp_history.size
          comp_history[block_index].each do |c|
            named_blocks[block_name] << c
          end
          block_index += 1
        end
      end

      course.each do |c|
        @comp << c
      end
 
    end
    #puts "Have comp: #{@comp}"
    return @comp
  end

end



class Touch
  # Internal representations of arrays are 0-based
  # External representations will be 1-based (human)
  
  attr_reader :row, :false_rows, :musicals, :start_stroke, :start_six, :start_offset

  def initialize(n, start_six = QUICK, six_offset = 3)
    @row = Array(1..n)
    @rounds = Array(1..n)
    @n = n
    @history = []
    @six_type = start_six
    @six = 0
    @start_stroke = HAND
    @offset = six_offset
    @start_offset = six_offset
    @start_six = @six_type
    @pn = []
    @pn[QUICK] = [[0], [2], [0], [2], [0], [n - 1], [n - 3], [n - 3, n - 2, n - 1]]
    @pn[SLOW] = [[2], [0], [2], [0], [2], [n - 1], [n - 3], [n - 3, n - 2, n - 1]]
    @comp = [PLAIN] * 22
    
    @truth = nil
    @false_rows = []
    @musicals = {}
  end

  def go
    change until finished?
  end

  def is_true?
    return @truth unless @truth.nil?
    @truth = true
    testcase = []
    @history.map{|row| testcase << stringify(row)}
    while testcase.size > 0
      testrow = testcase.pop
      if testcase.include? testrow
        @truth = false
        @false_rows << testrow unless @false_rows.include? testrow
      end
    end
    @truth
  end

  def set_comp(comp)
    cp = CompParser.new(@n)
    @comp = cp.parse(comp)
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

  def change
    nrow = []
    #puts "Six is: #{@six}, comp has #{@comp.size}"
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
          musicals[name] ||= 0 and musicals[name] += 1
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


