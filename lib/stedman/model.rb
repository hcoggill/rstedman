#!/usr/bin/env ruby

require 'stedman'

include Stedman

class Model 
  attr_reader :num_bells, :show_all_rows

  def initialize
  end

  def start
    @touch = Touch.new(11)
    @touch.set_comp "1.4.5.6.7.s9.s16.18\n4.5.6.7.s10.13.14.s16.17.19.22"
    @touch.go
    @highlighted = nil
    @show_all_rows = 1
    @num_bells = @touch.all_bells
  end

  def set_call(row)
  end
 
  def all_rows(state)
    @show_all_rows = state
  end

  def add_course
  end

  def remove_course
  end 

  def info
    "Touch has #{@touch.rows.length} changes (#{@touch.courses.length} courses), and is #{@touch.is_true?}"
  end

  def set_data(widget, parent = nil, new_model = true)
    num_rows = @touch.courses.max * 6
    num_cols = @touch.courses.length

    if new_model == false
      model = widget.model
    else
      model = Qt::StandardItemModel.new(num_rows, num_cols)
    end
    # Set up "rounds is the Nth blow of a Y six"
    offset = @touch.start_offset
    stroke = @touch.start_stroke
    six_type = @touch.start_six
    six = 0
    changes = 0
    last_six_calling = []
    course = 0
    course_offset = 0
    hidden = []

    @touch.rows.each_index do |row|
    
      offset += 1
      course_offset += 1
      changes += 1
      stroke = (stroke + 1) % 2
      if offset == 6
        offset = 0
        six += 1
        six_type = (six_type + 1) % 2
        if (course_offset / 6) >= @touch.courses[course]
          course_offset = 0
          course += 1
        end
      end

        #item = Qt::StandardItem.new @touch.printable(row, col)
        #if @touch.rows[row][col] == @highlighted
        #  item.setBackground Qt::Brush.new(Qt::red)
        #else
        #  item.setBackground Qt::Brush.new(Qt::white)
        #end
      str = @touch.stringify(@touch.rows[row])
      if @touch.num_bells != @touch.all_bells
        str << @touch.bell_to_str(@touch.all_bells)
      end


      labelling = ''
      # add space for callings
      if offset == 5
        labelling = ' '
        calling = @touch.comp[six]
        labelling = '-' if calling == Stedman::BOB
        labelling = 's' if calling == Stedman::SINGLE
        last_six_calling << labelling
      end
 
      # this hackery is to show the bizarre offet call/sixends used by composers
      if @faaaake_show_all_rows != 0
        str << ' ' << labelling
        last_six_calling.pop
      else
        if offset == 5 and six > 0
          str << ' ' << last_six_calling.first
          last_six_calling.shift
        end
      end 

      item = Qt::StandardItem.new str
      if labelling != '' and @show_all_rows != 0
        item.setBackground(Qt::Brush.new(Qt::magenta))
      end
      #puts "Setting item #{course_offset}, #{course}, #{item}"
      model.setItem(course_offset, course, item)

      if course == 0

	if @show_all_rows == 0 and (offset % 6) != 0
          hidden << course_offset
        end

        model.setVerticalHeaderItem(row, Qt::StandardItem.new("#{six + 1}/#{changes} #{stroke == HAND ? 'H' : 'B'}"))
      end

    end

    (@touch.courses.max * 6).times do |idx|
      if hidden.include? idx
        widget.setRowHidden(idx, true)
      else
        widget.setRowHidden(idx, false)
      end
    end

    if new_model == true
      widget.setModel(model)
    end
    
  end

  def update_rows(i, j)
  end
  

  def on_selection()
    puts "Selection changed!"
  end

end

