require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe HimaAttribute do
  before(:each) do
    @valid_attributes = { :name => :name, :type => :string, :options => {:limit => 40} }
    @hima_attr = HimaAttribute.new
  end
  
  it "initialize should accept an optional hash with optional ':name', ':type', ':options' keys" do
    @hima_attr = HimaAttribute.new(@valid_attributes)
  end

  it "should respond to a method name" do
    @hima_attr.respond_to?(:name).should be_true
  end
  
  it "should respond to a method attribute_type" do
    @hima_attr.respond_to?(:type).should be_true
  end
  
  it "should respond to a method options" do
    @hima_attr.respond_to?(:options).should be_true
  end
  
  it "method name should return the attributes' name" do
    @hima_attr.name = :name
    @hima_attr.name.should == :name
  end
  
  it "method type should return the attributes' type" do
    @hima_attr.type = :some_type
    @hima_attr.type.should == :some_type
  end
  
  it "method type should return the attributes' options hash" do
    @hima_attr.options = {:some_key => "some_value"}
    @hima_attr.options.should == {:some_key => "some_value"}
  end
  
  it "should respond to a method attributes" do
    @hima_attr.respond_to?(:attributes).should be_true
  end
  
  it "method attributes should return an attributes hash" do
    @hima_attr.attributes.should == {:name => nil, :type => nil, :options => {}}
  end
  
  it "attributes= should take a hash as an argument and set name, attributes, and options" do
    @hima_attr.attributes = {:name => :attr_name, :type => :string, :options => {:limit => 40}}
    @hima_attr.name.should == :attr_name
    @hima_attr.type.should == :string
    @hima_attr.options.should == {:limit => 40}
  end
  
  it "should respond to method ==" do
    @hima_attr.respond_to?(:==).should be_true
  end
  
  it "method ==(other) should return true if all attributes are equal to the other's and false otherwise" do
    @other = HimaAttribute.new
    @other.attributes = @hima_attr.attributes
    @hima_attr.should == @other
    @hima_attr.name = @other.name.to_s + "blah!"
    @hima_attr.should_not == @other
  end
  
  it "should respond to method =~" do 
    @hima_attr.respond_to?(:=~).should be_true
  end
  
  it "method =~(other) should return true if name and type are equal to the other's and false otherwise" do
    @other = HimaAttribute.new
    @other.name = @hima_attr.name
    @other.type = @hima_attr.type
    @hima_attr.should =~ @other
    @other.name = @hima_attr.name.to_s + "blah!"
  end
  
  it "should respond to a method valid?" do
    @hima_attr.respond_to?(:valid?).should be_true    
  end
  
  it "should be valid if all its attributes are valid" do
    @hima_attr.attributes = @valid_attributes
    @hima_attr.should be_valid
  end
  
  it "should not be valid unless it's name is a symbol" do
    @hima_attr.attributes = @valid_attributes.except(:name)
    @hima_attr.should_not be_valid
    @hima_attr.name = "name"
    @hima_attr.should_not be_valid
  end
     
  it "should not be valid unless it's type is a symbol" do
    @hima_attr.attributes = @valid_attributes.except(:type)
    @hima_attr.should_not be_valid    
  end
  
  it "should not be valid unless it's type is a valid data type" do
    @hima_attr.attributes = @valid_attributes.except(:type)
    @hima_attr.type = :fake_type
    @hima_attr.should_not be_valid    
  end  
  
  it "should not be valid if it's options have an invalid key" do
    @hima_attr.attributes = @valid_attributes
    @hima_attr.options[:invalid_key] = :some_crazy_value
    @hima_attr.should_not be_valid    
  end
  
  it "should not be valid if option[:limit] is not an integer" do
    @hima_attr.attributes = @valid_attributes
    @hima_attr.options[:limit] = 3.45
    @hima_attr.should_not be_valid  
  end
  
  it "should not be valid if option[:default] is not the same type as the attribute" do
    @hima_attr.attributes = @valid_attributes
    @hima_attr.options[:default] = 3.45
    @hima_attr.should_not be_valid  
  end

  it "should not be valid if option[:null] is not a boolean" do
    @hima_attr.attributes = @valid_attributes
    @hima_attr.options[:null] = 3.45
    @hima_attr.should_not be_valid  
  end
  
  it "should not be valid if it is a decimal and option[:precision] is not an integer" do
    @hima_attr.name = :my_decimal
    @hima_attr.type = :decimal
    @hima_attr.should be_valid
    @hima_attr.options[:precision] = "blah blah"
    @hima_attr.should_not be_valid  
  end
  
  it "should not be valid if it has option[:scale] defined without also defining option[:precision]" do
    @hima_attr.name = :my_decimal
    @hima_attr.type = :decimal
    @hima_attr.should be_valid
    @hima_attr.options[:scale] = 3
    @hima_attr.should_not be_valid
  end
  
  it "should not be valid if it is a decimal and option[:scale] is not an integer" do
    @hima_attr.name = :my_decimal
    @hima_attr.type = :decimal
    @hima_attr.options[:precision] = 5
    @hima_attr.should be_valid
    @hima_attr.options[:scale] = "blah blah"
    @hima_attr.should_not be_valid  
  end
  
end
