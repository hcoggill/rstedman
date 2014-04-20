require 'rspec'
require_relative 'model'

describe Model do
  context 'Basic tests' do
    before :each do
      @model = Model.new
      @model.start
    end

    it 'should have 11 bells' do
      @model.num_bells.should == 12
    end

    it 'should show all rows' do
      @model.show_all_rows.should == 1
    end

    it 'should be able to change showing all rows' do
      @model.all_rows 2
      @model.show_all_rows.should == 2
      @model.all_rows 1
      @model.show_all_rows.should == 1
    end

    it 'should nicely summarise the touch' do
      @model.info.should == 'Touch has 264 changes (2 courses), and is true'
    end

  end

  

end

