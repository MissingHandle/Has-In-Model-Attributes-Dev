require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe HimaDbMigration do
  
  before :each do 
    @migration = HimaDbMigration.new
    @valid_name = "valid_migration_name"
    @valid_delta = HimaDbDelta.new
    @valid_delta.model_name = "MyModel"
    @valid_delta.command = :add_column
    @valid_delta.options = {:column_name => :age, :column_type => :date}
  end
  
  it "should have a name attribute" do
    @migration.respond_to?(:name).should be_true
    @migration.name = "The_Name_of_Some_Migration"
    @migration.name.should == "The_Name_of_Some_Migration"
  end
  
  it "should have a deltas attribute, initialized as an empty array" do
    @migration.respond_to?(:deltas).should be_true
    @migration.deltas.should == []
  end
  
  it "method empty? should return true if no there are no db_deltas" do
    @migration.empty?.should be_true
  end
  
  it "method add_delta should add a delta to the deltas_array" do
    @migration.add_delta(@valid_delta)
    @migration.deltas.include?(@valid_delta).should be_true
  end
  
  it "method add_delta should return false if it is passed an invalid delta" do
    @invalid_delta = @valid_delta
    @invalid_delta.command = :foo
    @migration.add_delta(@invalid_delta).should be_false
  end
  
  it "method add_delta should not add an invalid delta" do
    @invalid_delta = @valid_delta
    @invalid_delta.command = :foo
    @migration.add_delta(@invalid_delta)
    @migration.deltas.should == []
  end
  
  it "method valid? should return true with all valid attributes" do
    @migration.name = @valid_name
    @migration.add_delta(@valid_delta)
    @migration.should be_valid
  end
  
  it "method valid? should return false without a name" do
    @migration.add_delta(@valid_delta)
    @migration.should_not be_valid
  end
  
  it "method valid? should return false if it is empty" do
    @migration.name = @valid_name
    @migration.should_not be_valid
  end
  
  it "method valid? should return false if one of it's deltas is invalid" do
    @migration.name = @valid_name
    @invalid_delta = @valid_delta
    @invalid_delta.command = :foo
    @migration.add_delta(@invalid_delta)
    @migration.should_not be_valid
  end

  it "method make should take two HimaModels and create all the necessary deltas to make the two equivalent" do
    @model_a, @model_b = HimaModel.new, HimaModel.new
    @model_a.name = "MyModel"
    a = HimaAttribute.new({:name => :name, :type => :string, :options => {:limit => 60}})
    @model_a.add(a)
    @delta_1, @delta_2 = HimaDbDelta.new, HimaDbDelta.new
    @delta_1.model_name, @delta_2.model_name = "MyModel", "MyModel"
    @delta_1.command, @delta_2.command = :create_table, :add_column
    @delta_1.options, @delta_2.options = {}, {:column_name=> :name, :column_type=>:string, :limit => 60}
    @migration.make(@model_a, @model_b)
    @migration.deltas.should == [@delta_1, @delta_2]
  end
    
  it "method as_text_array should return an array of strings, each element of which is one valid migration action" do
    @model_a, @model_b = HimaModel.new, HimaModel.new
    @model_a.name = "MyModel"
    a = HimaAttribute.new({:name => :name, :type => :string, :options => {:limit => 60}})
    @model_a.add(a)
    @migration.make(@model_a, @model_b)
    @migration.as_text_array.should == ["create_table :my_models", "add_column :my_models, :name, :string, :limit => 60"]
  end

end