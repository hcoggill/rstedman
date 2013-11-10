
# want to be able to input some calls, like 1, 3, s4, 6-11, 18; and display the
# length of the touch, the truth, the musical value, optionally the sixes, six+1s, or 
# all changes
# also want a git-style database of comps...? erm, not sure

class Touch
  # Internal representations of arrays are 0-based
  # External representations will be 1-based (human)

  QUICK = 0
  SLOW = 1
  PLAIN = 0
  BOB = 1
  SINGLE = 2

  attr_reader :row, :false_rows

  def initialize(n, start_six = QUICK, six_offset = 3)
    @row = Array(1..n)
    @rounds = Array(1..n)
    @n = n
    @history = []
    @six_type = start_six
    @six = 0
    @offset = six_offset
    @pn = []
    @pn[QUICK] = [[0], [2], [0], [2], [0], [n - 1], [n - 3], [n - 3, n - 2, n - 1]]
    @pn[SLOW] = [[2], [0], [2], [0], [2], [n - 1], [n - 3], [n - 3, n - 2, n - 1]]
    @comp = [PLAIN] * 22
    
    @truth = nil
    @false_rows = []
  end

  def go
    change until finished?
  end

  def is_true?
    return @truth unless @truth.nil?
    @truth = true
    testcase = Array.new(@history)
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
    # assume lines are a course
    # calls are separated, e.g. 1, 3, s4 s6 s9
    # non-standard course length needs to be in brackets, e.g. 1, 19 (23)
    # named blocks need to be in square brackets, can extend more than 1 course...
    #  e.g. 1, 3, 20 [AA]	# means this and previous course are "A"
 
    @comp = []
    comp_history = []
    named_blocks = {}
    comp.each_line do |line|
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

      course_len = course_length
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
    puts "Have comp: #{@comp}"
  end

  def rows
    @history
  end

  def course_length
    @n * 2
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

puts 'Prog'
touch = Touch.new(11)
puts "#{touch.num_bells} bells"

#touch.set_comp comprja
touch.set_comp compallton2

puts "Starting to ring"
touch.go
puts "Starting to prove"

puts "Touch has #{touch.rows.size} rows and is #{touch.is_true?} #{touch.rounds? ? "" : "but does not end in rounds!"}"

touch.rows.each do |row|
  if touch.false_rows.include? row
    puts "FALSE #{row}"
  else
    #puts "Row:  #{row}"
  end
end


