#!/usr/bin/env ruby

require 'Qt4'

class Model

  def initialize
    puts 'New model'
  end

  def start
  end

  def set_data(widget)
    @model = Qt::StandardItemModel.new(5, 2)
    5.times do |row|
      2.times do |col|
        item = Qt::StandardItem.new "Row #{row}, Col #{col}"
        @model.setItem(row, col, item)
      end
    end
    widget.setModel(@model)
  end

end

