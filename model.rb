#!/usr/bin/env ruby

require_relative 'stedman.rb'
require 'Qt4'

include Stedman

class Del < Qt::AbstractItemDelegate
  def initialize(model, parent = nil)
    puts "New del"
    @model = model
    super parent
  end

  def paint(painter, option, index)
    puts "Paint"
    painter.fillRect(option.rect, option.palette.highlight())
  end

  def sizeHint(option, index)
    puts "Sizehint"
    Qt::Size.new(45, 15)
  end

end

class Model 
  attr_reader :num_bells

  def initialize
    puts 'New model'
    @options = {}
    @options[:showSixes] = false
    super
  end

  def start
    @touch = Touch.new(11)
    @touch.go
    @highlighted = nil
    @show_all_rows = 1
    @num_bells = @touch.all_bells
  end

  def set_highlighted(row, column)
    #puts "Checking index #{row} #{column}"
    @highlighted = @touch.rows[row][column]
  end
 
  def set_call(row)

  end
 
  def all_rows(state)
    puts "State was #{@show_all_rows}, is #{state}"
    @show_all_rows = state
  end

  def set_data(widget, parent = nil, new_model = false)
    puts "New data"
    if new_model == false
      model = widget.model
    else
      model = Qt::StandardItemModel.new(@touch.rows.length, 1)
    end
    offset = @touch.start_offset
    stroke = (@touch.start_stroke + 1) % 2
    six_type = @touch.start_six
    six = 1
    changes = 0
    @touch.rows.each_index do |row|
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

      labelling = ' '
      # add space for callings
      if offset == 5
        calling = @touch.comp[six]
        labelling = '-' if calling == Stedman::BOB
        labelling = 's' if calling == Stedman::SINGLE
      end
      str << ' ' << labelling
      item = Qt::StandardItem.new str
      model.setItem(row, 0, item)

      offset += 1
      changes += 1
      stroke = (stroke + 1) % 2
      if offset == 6
        offset = 0
        six += 1
        six_type = (six_type + 1) % 2
      end
      model.setVerticalHeaderItem(row, Qt::StandardItem.new("#{six}/#{changes} #{stroke == HAND ? 'H' : 'B'}"))
    end

    if new_model == true
      widget.setModel(model)
    end
    
    if @show_all_rows == 0
      @touch.rows.each_index do |row|
        if (row + @touch.start_offset - 2) % 6 != 0
          widget.setRowHidden(row, true)
        end       
      end    
    else
      @touch.rows.each_index do |row|
        widget.setRowHidden(row, false)
      end
    end
  end

  def update_rows(i, j)
    

  end
  

  def on_selection()
    puts "Selection changed!"
  end

end

