#!/usr/bin/env ruby
require_relative 'model.rb'

require 'Qt4'
require 'qtuitools'

class View < Qt::Widget

  def initialize(uifile, app, model, args)
    super nil
    @model = model
    @app = app

    ui_loader = Qt::UiLoader.new
    ui_file = Qt::File.new uifile
    ui_file.open Qt::File::ReadOnly
    @widget = ui_loader.load(ui_file, self)
    ui_file.close
    table = find_child(Qt::TableView, 'tableView')
    @model.set_data(table)
    table.horizontalHeader.setResizeMode(Qt::HeaderView::Fixed)
    table.verticalHeader.setResizeMode(Qt::HeaderView::Fixed)
    #table.setModel(@model)
    table.selectionModel.connect SIGNAL('selectionChanged(const QItemSelection &, const QItemSelection &)'), self, :on_selection

    @widget.show
    @app.exec

  end

  def on_selection(x,y)
    puts "x is: #{x}, y is #{y}"
    @model.on_selection()
  end
    
end


app = Qt::Application.new ARGV

model = Model.new
model.start

view = View.new('form.ui', app, model, ARGV)

