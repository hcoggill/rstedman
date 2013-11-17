#!/usr/bin/env ruby

require_relative 'stedman.rb'
require 'Qt4'

include Stedman

class Model 

  def initialize
    puts 'New model'
    @options = {}
    @options[:showSixes] = false
    super
  end

  def start
    @touch = Touch.new(11)
    @touch.go
  end

  def set_data(widget)
    @model = Qt::StandardItemModel.new(@touch.rows.length, @touch.all_bells)
    offset = @touch.start_offset
    stroke = (@touch.start_stroke + 1) % 2
    six_type = @touch.start_six
    six = 1
    changes = 0
    @touch.rows.each_index do |row|
      @touch.rows[row].each_index do |col|
        item = Qt::StandardItem.new @touch.printable(row, col)
        @model.setItem(row, col, item)
      end
      if @touch.num_bells != @touch.all_bells
        item = Qt::StandardItem.new @touch.bell_to_str(@touch.all_bells)
        @model.setItem(row, @touch.rows[row].size, item) 
      end
      offset += 1
      changes += 1
      stroke = (stroke + 1) % 2
      if offset == 6
        offset = 0
        six += 1
        six_type = (six_type + 1) % 2
      end
      
      @model.setVerticalHeaderItem(row, Qt::StandardItem.new("#{six}/#{changes} #{stroke == HAND ? 'H' : 'B'}"))
    end
    widget.setModel(@model)
    
    @touch.rows.each_index do |row|
      if (row + @touch.start_offset - 2) % 6 != 0
        widget.setRowHidden(row, true)
      end       
    end

  end

  def on_selection()
    puts "Selection changed!"
  end

end

