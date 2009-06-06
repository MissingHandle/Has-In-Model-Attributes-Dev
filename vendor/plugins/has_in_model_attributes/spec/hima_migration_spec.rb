require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe HimaMigration do
  
  it "should have a class method get_model_filenames which returns an array of all model's names" do
    models = HimaMigration.get_model_filenames
    models.should == ["my_model.rb"]
  end
  
  it "should have a method get_db_schema which gets the schema for a model from ActiveRecord" do
    @ar_model = HimaMigration.get_db_schema(MyModel)
    @ar_model.name.should == "MyModel"
    @ar_model.hima_attributes.should == {
      :updated_at => HimaAttribute.new({ :name => :updated_at, :type => :datetime, :options => {} }),
      :created_at => HimaAttribute.new({ :name => :created_at, :type => :datetime, :options => {} }), 
      :name => HimaAttribute.new({ :name => :name, :type => :string, :options => {} }), 
      :id => HimaAttribute.new({ :name => :id, :type => :integer, :options => {} }) }
  end
  
  it "should have a method get_hima_schema which gets the schema for 1 model from the model file" do
    HimaMigration.get_hima_schema(MyModel).should == false
    MyModel.has_in_model_attributes
    MyModel.define_attribute(:name, :string, :limit => 24)
    model = HimaMigration.get_hima_schema(MyModel)
    model.hima_attributes.should == {:name => HimaAttribute.new({:name => :name, :type => :string, :options => {:limit => 24}})}
  end
  
  it "method write_one_migration writes a migration file, given the appropriate up and down migrations" do
    MyModel.hima_model_representation = HimaModel.new
    MyModel.hima_model_representation.name = "MyModel"
    MyModel.define_attribute(:id, :integer)
    MyModel.define_attribute(:created_at, :datetime)
    MyModel.define_attribute(:updated_at, :datetime)
    MyModel.define_attribute(:name, :string, :limit => 40)
    MyModel.define_attribute(:test_1, :integer)
    MyModel.define_attribute(:test_2, :string)
    MyModel.define_attribute(:test_3, :datetime)
    ar_model = HimaMigration.get_db_schema(MyModel)
    hima_model = HimaMigration.get_hima_schema(MyModel)
    migration= HimaDbMigration.new
    migration.make_self(hima_model, ar_model)
    f = HimaMigration.write_one_migration(MyModel, migration)
    f.close
    false #have to inspect manually
  end
  
  it "should have a method do_migrations which writes and runs all necessary migrations to unify two differing DB schemas" do
  end
  
end