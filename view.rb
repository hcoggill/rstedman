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
    @table = find_child(Qt::TableView, 'tableView')
    @model.set_data(@table, self, true)

    @label = find_child(Qt::Label, 'info')
    @label.text = @model.info

    @table.horizontalHeader.setResizeMode(Qt::HeaderView::Fixed)
    @table.verticalHeader.setResizeMode(Qt::HeaderView::Fixed)
    #table.setModel(@model)
    @table.selectionModel.connect SIGNAL('selectionChanged(const QItemSelection &, const QItemSelection &)'), self, :on_selection
    @allRows = find_child(Qt::CheckBox, 'allRows')
    @allRows.connect SIGNAL('stateChanged(int)'), self, :all_rows

    find_child(Qt::PushButton, 'buttonLeft').connect(SIGNAL('clicked()'), self, :button_left)
    find_child(Qt::PushButton, 'buttonRight').connect(SIGNAL('clicked()'), self, :button_right)

    @widget.show
    @app.exec

  end

  def on_selection(x,y)
    # take the first selection index and set this to be highlighted
    i = x.indexes.first
    @model.set_call(i.row)
    update_state
  end

  def button_left
    @model.remove_course
    update_state
  end

  def button_right
    @model.add_course
    update_state
  end

  def update_state
    @model.set_data(@table, self)
    puts "Got model #{@model}, info #{@model.info}"
    @label.text = @model.info    
  end

  def all_rows(state)
    @model.all_rows state
    @model.set_data @table, self
  end
    
end


app = Qt::Application.new ARGV

model = Model.new
model.start

view = View.new('form.ui', app, model, ARGV)

