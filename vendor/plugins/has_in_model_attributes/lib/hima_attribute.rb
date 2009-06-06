class HimaAttribute < Object
  #structured representation of a model attribute
  
  # From ActiveRecord::ConnectionAdapters::TableDefinition
  # The type parameter is normally one of the migrations native types, 
  #which is one of the following: :primary_key, :string, :text, :integer, 
  #:float, :decimal, :datetime, :timestamp, :time, :date, :binary, :boolean. 
  ValidTypes = [ :primary_key, :integer, :float, :decimal, :string, 
    :text, :datetime, :date, :time, :timestamp, :binary, :boolean]
  
  # From ActiveRecord::ConnectionAdapters::TableDefinition
  # Available options are (none of these exists by default):
  # 
  #     * :limit - Requests a maximum column length. This is number of characters for :string and :text columns and number of bytes for :binary and :integer columns.
  #     * :default - The column‘s default value. Use nil for NULL.
  #     * :null - Allows or disallows NULL values in the column. This option could have been named :null_allowed.
  #     * :precision - Specifies the precision for a :decimal column.
  #     * :scale - Specifies the scale for a :decimal column.
  # 
  ValidBaseOptionKeys = [ :default, :null ]
  ValidDecimalOptionKeys = [ :precision, :scale ] + ValidBaseOptionKeys
  ValidIntStringOptionKeys = [ :limit ] + ValidBaseOptionKeys  

  attr_accessor :name, :type, :options
  
  #accepts an optional hash as an argument 
  #which can specify the name, type and options attributes
  def initialize(*args)
    if args and args.first.is_a?(Hash)
      self.name = args.first[:name].to_sym || nil
      self.type = args.first[:type] || nil
      self.options = args.first[:options] || {}
    elsif args && args.first
      raise "Error! HimaAttribute.new expected a hash and instead got #{args.first.class}"
    else
      self.name = nil
      self.type = nil
      self.options = {}
    end
  end
  
  def attributes
      {:name => self.name, :type => self.type, :options => self.options}
  end

  def attributes=(attr_hash)
    attr_hash.keys do |key|
      unless self.attributes.keys.any? {|k| k == key}
        raise "Invalid Attribute for HimaAttribute: '#{key}', expecting one of #{self.attributes.keys}"
      end
    end
    self.name = attr_hash[:name] if attr_hash.key?(:name)
    self.type = attr_hash[:type] if attr_hash.key?(:type)
    self.options = attr_hash[:options] if attr_hash.key?(:options)
  end


  def ==(other)
    return false unless self.name == other.name
    return false unless self.type == other.type
    equal_options = true
    equal_options = false unless self.options[:default] == other.options[:default]
    equal_options = false unless self.options[:null] == other.options[:null]
    equal_options = false unless self.options[:precision] == other.options[:precision]
    equal_options = false unless self.options[:scale] ==  other.options[:scale  ]
    equal_options = false unless self.options[:limit] == other.options[:limit]
    equal_options
  end

  def =~(other)
    (self.name == other.name) && (self.type == other.type)
  end
  
  def valid?
    valid_name? && valid_type? && valid_option_keys? && valid_option_values?
  end
  
  def valid_name?
    self.name.is_a?(Symbol)
  end
  
  def valid_type?
    self.type.is_a?(Symbol) && ValidTypes.any? {|type| type == self.type}
  end
  
  def valid_option_keys?
    if [:integer, :binary, :string, :text].include?(self.type)
      self.options.keys.all? { |key| ValidIntStringOptionKeys.include?(key) }
    elsif self.type == :decimal
      self.options.keys.all? { |key| ValidDecimalOptionKeys.include?(key) }
    else
      self.options.keys.all? { |key| ValidBaseOptionKeys.include?(key) }
    end
  end
  
  def valid_option_values?
    valid = true
    if self.options.has_key?(:limit)
      valid = false unless self.options[:limit].is_a?(Integer)
    end
    if self.options.has_key?(:default)
      valid = false unless self.options[:default].class.ancestors.include?(self.type.to_s.capitalize.constantize)
    end
    if self.options.has_key?(:null)
      valid = false unless self.options[:null].class == (TrueClass or FalseClass)
    end
    if self.options.has_key?(:precision)
      valid = false unless self.options[:precision].is_a?(Integer)
    end
    if self.options.has_key?(:scale)
      valid = false unless self.options.has_key?(:precision) and self.options[:scale].is_a?(Integer)
    end
    valid
  end

end