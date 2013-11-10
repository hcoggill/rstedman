
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

  attr_reader :row

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
  end

  def rows
    @history
  end

  def num_bells
    @n
  end

  def finished?
    @row == @rounds and @history.size > 0
  end

  def change
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
    
    @history << @row
    @row = nrow
    puts "New row: #{nrow}"
  end
  
  
end



puts 'Prog'
touch = Touch.new(11)
puts "#{touch.num_bells} bells"
touch.go
puts "Touch has #{touch.rows.size} rows and is #{touch.is_true?}"

