require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe HimaDbMigration do
  
  before :each do 
    @migration = HimaDbMigration.new
    @valid_up_delta, @valid_down_delta = HimaDbDelta.new, HimaDbDelta.new
    @valid_up_delta.model_name, @valid_down_delta.model_name = "MyModel", "MyModel"
    @valid_up_delta.command, @valid_down_delta.command = :add_column, :remove_column
    @valid_up_delta.options = {:column_name => :age, :column_type => :date}
    @valid_down_delta.options = {:column_name => :age}
  end
  
  it "should have an up_deltas attribute, initialized as an empty array" do
    @migration.respond_to?(:up_deltas).should be_true
    @migration.up_deltas.should == []
  end
  
  it "should have a down_deltas attribute, initialized as an empty array" do
    @migration.respond_to?(:up_deltas).should be_true
    @migration.down_deltas.should == []
  end
  
  it "method empty? should return true if no there are no db_deltas" do
    @migration.empty?.should be_true
  end
  
  it "method valid? should return false if it is empty" do
    @migration.should_not be_valid
  end
  
  it "method valid? should return false if one of it's deltas is invalid" do
    @invalid_delta = @valid_up_delta
    @invalid_delta.command = :foo
    @migration.send(:add_delta, @invalid_delta)
    @migration.should_not be_valid
  end
  
  it "method valid? should return true with all valid attributes" do
    @migration.send(:add_delta, @valid_up_delta, "up")
    @migration.send(:add_delta, @valid_down_delta, "down")
    t = @valid_up_delta
    @migration.up_deltas.should == [t]
    t = @valid_down_delta
    @migration.down_deltas.should == [t]
    
  end
  
  it "method make_self should take two HimaModels and create all the necessary deltas to make the two equivalent" do
    @model_a, @model_b = HimaModel.new, HimaModel.new
    @model_a.name = "MyModel"
    a = HimaAttribute.new({:name => :name, :type => :string, :options => {:limit => 60}})
    @model_a.add(a)
    @delta_1, @delta_2 = HimaDbDelta.new, HimaDbDelta.new
    @delta_1.model_name, @delta_2.model_name = "MyModel", "MyModel"
    @delta_1.command, @delta_2.command = :create_table, :add_column
    @delta_1.options, @delta_2.options = {}, {:column_name=> :name, :column_type=>:string, :limit => 60}
    @migration.make_self(@model_a, @model_b)
    @migration.up_deltas.should == [@delta_1, @delta_2]
  end
    
  #PRIVATE METHOD TESTING...might be removed in future...
  it "method add_delta should add a delta to the up_deltas array" do
    @migration.send(:add_delta, @valid_up_delta)
    @migration.up_deltas.include?(@valid_up_delta).should be_true
  end
  
  it "method add_delta should add a delta to the down_deltas array" do
    @migration.send(:add_delta, @valid_down_delta, "down")
    @migration.down_deltas.include?(@valid_down_delta).should be_true
  end
  
  it "method add_delta should return false if it is passed an invalid delta" do
    @invalid_delta = @valid_up_delta
    @invalid_delta.command = :foo
    @migration.send(:add_delta, @invalid_delta).should be_false
  end
  
  it "method add_delta should not add an invalid delta" do
    @invalid_delta = @valid_up_delta
    @invalid_delta.command = :foo
    @migration.send(:add_delta, @invalid_delta)
    @migration.up_deltas.should == []
  end
    
  it "method as_text_array should return an array of strings, each element of which is one valid migration action" do
    @model_a, @model_b = HimaModel.new, HimaModel.new
    @model_a.name = "MyModel"
    a = HimaAttribute.new({:name => :name, :type => :string, :options => {:limit => 60}})
    @model_a.add(a)
    @migration.make_self(@model_a, @model_b)
    @migration.send(:as_text_array, "up").should == ["create_table :my_models", "add_column :my_models, :name, :string, :limit => 60"]
  end

end