require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe HimaModel do
  
  before :each do 
    @valid_attributes = { :name => "ModelName", 
      :hima_attributes => { :name => 
          HimaAttribute.new({:name => "name", :type => :string}), 
        :some_count => HimaAttribute.new({:name => "some_count", :type => :integer}) 
    }}
    @valid2 = { :name => "ModelName", :hima_attributes => { :name => 
        HimaAttribute.new({:name => "name", :type => :string}), 
      :some_count => HimaAttribute.new({:name => "some_count", :type => :integer}) 
  }}
    @hima_model = HimaModel.new
  end
  
  it "should have an accessible attribute 'name'" do
    @hima_model.respond_to?(:name).should be_true
    @hima_model.name = "ModelName"
    @hima_model.name.should == "ModelName"
  end
  
  it "should have a readable attribute 'hima_attributes' initialized as an empty hash" do
    @hima_model.respond_to?(:hima_attributes).should be_true
    @hima_model.hima_attributes.should == {}
  end
  
  it "should respond to a method add which yields a HimaAttribute do be added" do
    @hima_model.respond_to?(:add).should be_true
  end
  
  it "add should add a HimaAttribute to the hima_attributes array" do
    old_size = @hima_model.hima_attributes.length
    @hima_model.add HimaAttribute.new({:name => "attr_name"})
    @hima_model.hima_attributes.length.should == (old_size + 1)
    @hima_model.hima_attributes.include?(:attr_name).should be_true
    @hima_model.hima_attributes[:attr_name].should == HimaAttribute.new({:name => "attr_name"})
  end
  
  it "method delete should remove a HimaAttribute from the HimaModel" do
    @hima_model = HimaModel.new(@valid_attributes)
    @hima_model.hima_attributes.length.should == 2
    @hima_model.delete(HimaAttribute.new(:name => "some_count", :type => :integer))
    @hima_model.hima_attributes.length.should == 1
  end
  
  it "method clear! which clears all HimaAttributes" do
    @hima_model = HimaModel.new(@valid_attributes)
    @hima_model.hima_attributes.length.should == 2
    @hima_model.clear!
    @hima_model.hima_attributes.length.should == 0
  end
  
  it "==(other) returns true if the two have the same name and hima_attributes" do
    @hima_model = HimaModel.new(@valid_attributes)
    @other = HimaModel.new(@valid2)
    @hima_model.should == @other
  end
  
  it "==(other) returns false if the two do not have the same model name" do
    @hima_model = HimaModel.new(@valid_attributes)
    @other = HimaModel.new(@valid2)
    @hima_model.should == @other
    @other.name = "BrandNewModelName"
    @hima_model.should_not == @other
  end
  
  it "==(other) returns false if the two do not have the same HimaAttributes" do
    @hima_model = HimaModel.new(@valid_attributes)
    @other = HimaModel.new(@valid2)
    @hima_model.should == @other
    @other.add HimaAttribute.new({:name => "attr_name", :type => :string})
    @hima_model.should_not == @other
  end
  
  it "=~(other) should return true if the two have the same model name and similar HimaAttributes" do
    @hima_model = HimaModel.new(@valid_attributes)
    @other = HimaModel.new(@valid2)
    @hima_model.should == @other
    @other.hima_attributes[:some_count].options[:limit] = 234
    @hima_model.should_not == @other
    @hima_model.should =~ @other
  end
  
  it "=~(other) should return false if the two do not have the same model name" do
    @hima_model = HimaModel.new(@valid_attributes)
    @other = HimaModel.new(@valid2)
    @hima_model.should =~ @other
    @other.name = "CrazyModelName"
    @hima_model.should_not =~ @other
  end
  
  it "=~(other) should return false if the two are off by at least 1 mismatching HimaAttribute(1)" do
    @hima_model = HimaModel.new(@valid_attributes)
    @other = HimaModel.new(@valid2)
    @hima_model.should =~ @other
    @hima_model.add HimaAttribute.new({:name => "walla", :type => :string})
    @hima_model.should_not =~ @other
  end
  
  it "=~(other) should return false if the two are off by at least 1 mismatching HimaAttribute(2)" do
    @hima_model = HimaModel.new(@valid_attributes)
    @other = HimaModel.new(@valid2)
    @hima_model.should =~ @other
    @other.hima_attributes[:some_count].name = "CrazyNewName"
    @hima_model.hima_attributes[:some_count].name.should_not == @other.hima_attributes[:some_count].name
    @hima_model.should_not == @other
    @hima_model.should_not =~ @other
  end
    
end