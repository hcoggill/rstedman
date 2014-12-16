#!/usr/bin/env ruby

require 'stedman'
require 'Qt4'
include Stedman

class Model < Qt::AbstractTableModel

  attr_reader :num_bells, :show_all_rows

  def initialize
    super
    @blank = Qt::Variant.new
  end

  def bark
    puts "I'm barking!"
  end

  def start
    @touch = Touch.new(11)
    @touch.set_comp "1.4.5.6.7.s9.s16.18\n4.5.6.7.s10.13.14.s16.17.19.22"
    @touch.go

    @highlighted = nil
    @show_all_rows = 1
    @num_bells = @touch.all_bells
    reset
  end

  def reset
    @num_rows = nil
    @num_columns = nil
  end

  # required override
  def rowCount(parent = Qt::ModelIndex.new)
    @num_rows ||= @touch.num_rows
  end

  # required override
  def columnCount(parent = Qt::ModelIndex.new)
    @num_columns  ||= @touch.num_columns
  end

  def data(index, role = Qt::DisplayRole)
    #puts "Data called: #{index.class}"
    if index.isValid
      Qt::Variant.new @touch.visual_course_row(index.column, index.row)
      

    else
      return @blank
    end
  end



  def add_course
  end

  def remove_course
  end 

  def info
    "Touch has #{@touch.rows.length} changes (#{@touch.courses.length} courses), and is #{@touch.is_true?}"
  end

  def on_selection()
    puts "Model: Selection changed!"
  end

end

