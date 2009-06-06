require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe HimaDbDelta do
  
  before :each do 
    @db_delta = HimaDbDelta.new
  end
  
  it "should have an attribute model_name" do
    @db_delta.respond_to?(:model_name).should be_true
    @db_delta.model_name = "ModelName"
    @db_delta.model_name.should == "ModelName"
  end
  
  it "should have an attribute migration_command" do
    @db_delta.respond_to?(:command).should be_true
    @db_delta.command = :add_column
    @db_delta.command.should == :add_column
  end
  
  it "should have an attribute options" do
    @db_delta.respond_to?(:options).should be_true
    @db_delta.options = {:limit => 24}
    @db_delta.options.should == {:limit => 24}
  end
  
  it "should respond to method valid?" do
    @db_delta.respond_to?(:valid?).should be_true
  end
  
  it "method valid should return true with valid attributes" do
    @db_delta.model_name = "ModelName"
    @db_delta.command = :add_column
    @db_delta.options = {:column_name => :name, :column_type => :string}
    @db_delta.should be_valid
  end
  
  it "method valid should return false if model_name is not in camelcase" do
    @db_delta.model_name = "bad_model_name"
    @db_delta.command = :add_column
    @db_delta.options = {:column_name => :name, :column_type => :string}
    @db_delta.should_not be_valid
  end
  
  it "method valid should return false if command is not a valid migration command" do
    @db_delta.model_name = "ModelName"
    @db_delta.command = :bad_command
    @db_delta.options = {:column_name => :name, :column_type => :string}
    @db_delta.should_not be_valid
  end
  
  it "method valid should return false if options have any invalid options" do
    @db_delta.model_name = "ModelName"
    @db_delta.command = :bad_command
    @db_delta.options = {:column_name => :name, :foo => :bar}
    @db_delta.should_not be_valid
  end
  
  it "should have a method clear!" do
    @db_delta.respond_to?(:clear!).should be_true
  end
  
  it "method clear! should clear all attributes" do
    @db_delta.model_name = "bad_model_name"
    @db_delta.command = :add_column
    @db_delta.options = {:column_name => :name, :column_type => :string}
    @db_delta.clear!
    @db_delta.model_name.should == ""
    @db_delta.command.should == nil
    @db_delta.options.should == {}
  end
  
  it "should ==other if the two have the same model_name, command, and options" do
    @other = HimaDbDelta.new
    @other.model_name = @db_delta.model_name
    @other.command = @db_delta.command
    @other.options = @db_delta.options
    @db_delta.should == @other
  end
  
  it "should have a method to_file_text" do
    @db_delta.respond_to?(:to_file_text).should be_true
  end
  
  it "method to_file_text should create the migration string for create table" do
    @db_delta.model_name = "ModelName"
    @db_delta.command = :create_table
    @db_delta.options = {:id => false, :force => true}
    @db_delta.to_file_text.should == "create_table :model_names, :force => true, :id => false"    
  end
  
  it "method to_file_text should create the migration string for rename table" do
    @db_delta.model_name = "ModelName"
    @db_delta.command = :rename_table
    @db_delta.options = {:new_name => "NewModelName"}
    @db_delta.to_file_text.should == "rename_table :model_names, :new_model_names"
  end
  
  it "method to_file_text should create the migration string for drop table" do
    @db_delta.model_name = "ModelName"
    @db_delta.command = :drop_table
    @db_delta.options = {:id => false, :force => true} #should successfully ignore options
    @db_delta.to_file_text.should == "drop_table :model_names"
  end
  
  it "method to_file_text should create the migration string for add column" do
    @db_delta.model_name = "ModelName"
    @db_delta.command = :add_column
    @db_delta.options = {:column_name => :some_column_name, :column_type => :string}
    @db_delta.to_file_text.should == "add_column :model_names, :some_column_name, :string"
  end

  it "method to_file_text should create the migration string for rename column" do
    @db_delta.model_name = "ModelName"
    @db_delta.command = :rename_column
    @db_delta.options = {:column_name => :some_column_name, :new_name => :new_column_name}
    @db_delta.to_file_text.should == "rename_column :model_names, :some_column_name, :new_column_name"
  end
  
  it "method to_file_text should create the migration string for change column" do
    @db_delta.model_name = "ModelName"
    @db_delta.command = :change_column
    @db_delta.options = {:column_name => :some_column_name, :new_type => :integer}
    @db_delta.to_file_text.should == "change_column :model_names, :some_column_name, :integer"
  end
  
  it "method to_file_text should create the migration string for remove column" do
    @db_delta.model_name = "ModelName"
    @db_delta.command = :remove_column
    @db_delta.options = {:column_name => :some_column_name}
    @db_delta.to_file_text.should == "remove_column :model_names, :some_column_name"
  end
  
  it "method to_file_text should create the migration string for add index" do
    @db_delta.model_name = "ModelName"
    @db_delta.command = :add_index
    @db_delta.options = {:column_name => :some_column_name, :index_name => "some_index_name", :unique => true}
    @db_delta.to_file_text.should == "add_index :model_names, :some_column_name, :name => 'some_index_name', :unique => true"
  end
  
  it "method to_file_text should create the migration string for remove index" do
    @db_delta.model_name = "ModelName"
    @db_delta.command = :remove_index
    @db_delta.options = {:column_name => :some_column_name}
    @db_delta.to_file_text.should == "remove_index :model_names, :some_column_name"
  end
  
end
