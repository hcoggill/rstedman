#!/usr/bin/env ruby

require 'Qt4'

class Model #< Qt::AbstractTableModel

  def initialize
    puts 'New model'
    super 
  end

  def start
  end

  def set_data(widget)
    @model = Qt::StandardItemModel.new(24, 12)
    24.times do |row|
      12.times do |col|
        item = Qt::StandardItem.new "#{(row + 1) * (col + 1)}"
        @model.setItem(row, col, item)
      end
    end
    widget.setModel(@model)
  end

  def flags(index)
    return Qt::ItemIsEnabled unless index.valid?
    Qt::ItemIsEnabled | Qt::ItemIsSelectable
  end

  def data(index, role = Qt::DisplayRole)
    return Qt::Variant.new unless index.valid?
    case role
    when Qt::DisplayRole
      return Qt::Variant.new (index.row + 1) * (index.column + 1)
    when Qt::ToolTipRole
      return Qt::Variant.new "#{index.row + 1}, #{index.column + 1}"
    else
      return Qt::Variant.new
    end
  end

  def headerData(section, orientation, role = Qt::DisplayRole)
    Qt::Variant.new
  end

  def rowCount(parent = Qt::ModelIndex.new)
    return 24
  end

  def columnCount(parent = Qt::ModelIndex.new)
    return 12
  end

end

