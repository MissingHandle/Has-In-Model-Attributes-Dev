class HimaModel < Object
  #a HimaModel is a collection of HimaAttributes

   attr_accessor :name
   attr_accessor :hima_attributes
   
   def initialize(*args)
     if args && args.first.is_a?(Hash)
       self.name = String.new(args.first[:name]) || ""
       self.hima_attributes = Hash.new
       if args.first[:hima_attributes]
         args.first[:hima_attributes].each_key do |attr_key|
           hima_attr = args.first[:hima_attributes][attr_key]
           self.hima_attributes[hima_attr.name.to_sym] = hima_attr
         end
       end
     else
       self.name = ""
       self.hima_attributes = {}
     end
   end
   
  def add(hima_attribute)
    expect_hima_attribute(hima_attribute)
    if self.hima_attributes.has_key?(hima_attribute.name.to_sym)
      raise "Duplicate Attribute Name Error! 
            Model #{self.name} has two attributes named #{hima_attribute.name}"
    else
      self.hima_attributes[hima_attribute.name.to_sym] = hima_attribute
    end
  end
   
  def delete(hima_attribute)
    expect_hima_attribute(hima_attribute)
    self.hima_attributes.delete(hima_attribute.name.to_sym)
  end

  # MUST TEST
  # 
  def each_attribute
    self.hima_attributes.each_key do |key|
      yield(self.hima_attributes[key])
    end
  end
  
  def has_exact_same?(hima_attribute)
    expect_hima_attribute(hima_attribute)   
    key = hima_attribute.name.to_sym
    self.hima_attributes.key?(key) && (hima_attribute == self.hima_attributes[key])
  end
  
  def has_with_name?(hima_attribute)
    expect_hima_attribute(hima_attribute)   
    key = hima_attribute.name.to_sym
    self.hima_attributes.key?(key)
  end
  
  # def has_similar?(hima_attribute)
  #   expect_hima_attribute(hima_attribute)   
  #   key = hima_attribute.name.to_sym
  #   self.hima_attributes.key?(key) &&
  #   self.hima_attributes[key] =~ hima_attribute
  # end
  
  ## --- End Must Test

  
  def clear!
    self.hima_attributes = {}
  end
  
  def ==(other)
    (self.name == other.name) && (self.hima_attributes == other.hima_attributes)
  end
  
  def =~(other)
    return false unless (self.name == other.name)
    return false unless (self.hima_attributes.length == other.hima_attributes.length)
    self.hima_attributes.each_key do |attr_key|
      return false unless other.hima_attributes.has_key?(attr_key) && other.hima_attributes[attr_key] =~ self.hima_attributes[attr_key]
    end
    true
  end
  
  private
  
  def expect_hima_attribute(hima_attribute)
    if(hima_attribute.class != HimaAttribute)
      raise "Error: expected an instance of HimaAttribute and got instance of #{hima_attribute.class}"
    end
    true
  end
  
end