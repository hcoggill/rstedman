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
  
  attr_reader :row, :false_rows, :musicals

  def initialize(n, start_six = QUICK, six_offset = 3)
    @row = Array(1..n)
    @rounds = Array(1..n)
    @n = n
    @history = []
    @six_type = start_six
    @six = 0
    @start_stroke = HAND
    @offset = six_offset
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

  def rows
    @history
  end

  def num_bells
    @n
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

comprja = "1.5.6.s9.12.14.15.16.17.18.19 (20) [a]\na"

compallton1 = <<EO1
5.7.8.10.11.s13.15.16 (20)
s1.9.10.s13.15.16.s22
s13.s15.18.s22
1.s7.s9.s13.s15.18.s22
s3.6.7.12
2.s3.s9.12.s15
3.4.12.s17.s19
3.4.12.16.17.18
3.4.s7.s9.s12.s17.18
3.4.s12.17.18 (23) 
EO1

compallton2 = <<EO2
1.5.6.s9.12.14-19 (20)
1.2.5.8.13.14.15.16.18.s21
6, 7, s9, 18
s16 18
s16 18
s16 18 [AAA]
s7, s9, 18
A
(1)
EO2

comppnm2 = <<EOF4
s1.2.s6.15.16.19
19
6 s19
6 19
19
19
5.s14.19
19
19
s6
6, s19
2.s6.s13.s15.s19
19
6
6 19
19
6 19
19
19
3.4.9.10.12.13.s15.16.17.s22.s24 (24) [AAAAAAAAAAAAAAAAAAA]
s1.2.6.s15.19
A
EOF4


coaker1 = <<EOF5
5004 Stedman Cinques

Composed by: Stephen A Coaker


 2314567890E  7  9 18 
 32415768        a
 21435678E90     b   
 1324         s     - |
 3412         s     - |
 4231         s     - |
 2413         s  s  - |A
 4321         s     - |
 3142         s     - |
 1234         s     - |
 123456E9780     c
 1234568709E     d
 2143            A   
 214357869E0     e
 21436578E90     f
 1234            A   
 153246E9780     g
 1234658709E     h
 2143            A   
 13579E24680     i
 2314567890E     j   
a = s1.s4.6.7.9.10.17.s18
b = 1.4.5.7.8.9.10.11.13.14.s16 (20)
c = 3.s8.s12.21
d = 1.2.3.s8.s12.21
e = 2.10.11.s15.20
f = s6.s10.13.s15.s17.s19.s22
g = 3.8.10.11.12.20.s21
h = 1.2.3.8.s9.11.s12.20.s21
i = s1.5.6.7.8.9.s11.14.16.17.18.20 (20)
j = 1.2.6.9.10.s15.17.23 (24)
Contains Queens; Tittums; Whittingtons; Double Whittingtons; all 56s; all 65s; 87 80s; all 5678E90; 6 E9780; 5 near misses;

EOF5
compcoaker1 = <<EOF6
s1.s4.6.7.9.10.17.s18
1.4.5.7.8.9.10.11.13.14.s16 (20)
s7 18
s7 18
s7 18
s7 s9 18
s7 18
s7 18
s7 18 [AAAAAAA]
3.s8.s12.21
1.2.3.s8.s12.21
A
2.10.11.s15.20
s6.s10.13.s15.s17.s19.s22
A 
3.8.10.11.12.20.s21
1.2.3.8.s9.11.s12.20.s21
A 
s1.5.6.7.8.9.s11.14.16.17.18.20 (20)
1.2.6.9.10.s15.17.23 (24)
EOF6

include Stedman
puts 'Prog'
touch = Touch.new(11)
puts "#{touch.num_bells} bells"
m = MusicGen.new(11)
pp m.named_changes

#touch.set_comp comprja
#touch.set_comp compallton2
touch.set_comp compcoaker1
#touch.set_comp comppnm2

puts "Starting to ring"
touch.go
puts "Starting to prove"

puts "Touch has #{touch.rows.size} rows" # and is #{touch.is_true?} #{touch.rounds? ? "" : "but does not end in rounds!"}"


#touch.rows.each do |row|
#  if touch.false_rows.include? row
#    puts "FALSE #{row}"
#  else
#    #puts "Row:  #{row}"
#  end
#end

touch.check_music
pp touch.musicals


