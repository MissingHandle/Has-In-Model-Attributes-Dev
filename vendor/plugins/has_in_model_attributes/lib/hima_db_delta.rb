class HimaDbDelta < Object
  #DbDelta = one migration command/one change to the database.
  
  require 'rubygems'
  require 'active_support/inflector'
  
  # * Adding a new table
  # * Renaming a table
  # * Removing a table
  
  # * Adding a column to an existing table
  # * Renaming a column
  # * Changing a column's type and options
  # * Removing a column
  
  # * Adding an index
  # * Removing an index

  TableCommands = [:create_table, :rename_table, :drop_table]
  ColumnCommands = [:add_column, :rename_column, :change_column, :remove_column]
  IndexCommands = [:add_index, :remove_index]
  Commands = TableCommands + ColumnCommands + IndexCommands
    
  ValidTableOptions = [:table_name, :id, :force, :new_name]
  ValidColumnOptions = [:column_name, :column_type, :new_name, :new_type,
    :default, :null, :limit, :precision, :scale]  
  ValidIndexOptions = [:column_name, :index_name, :unique]
  ValidOptions = ValidTableOptions + ValidColumnOptions + ValidIndexOptions
  
  attr_accessor :model_name, :command, :options
  
  def initialize
    self.model_name = ""
    self.command = nil
    self.options = {}
  end

  def valid?
    self.model_name != "" && self.model_name.camelize == self.model_name &&
    Commands.include?(self.command) && 
    if TableCommands.include?(self.command)
      self.options.keys.all? { |key| ValidTableOptions.include?(key)}
    elsif ColumnCommands.include?(self.command)
      self.options.key?(:column_name) && self.options.keys.all? { |key| ValidColumnOptions.include?(key)}
    else #IndexCommands.include?(self.command)
      self.options.key?(:column_name) && self.options.keys.all? { |key| ValidIndexOptions.include?(key)}
    end
  end

  def clear!
    self.model_name = ""
    self.command = nil
    self.options = {}
  end
  
  def ==(other)
    self.model_name == other.model_name && 
    self.command == other.command &&
    self.options == other.options
  end
  
  def to_file_text
    self.expect_valid_self
    migration_text = self.command.to_s
    migration_text = migration_text + " :" + self.model_name.tableize
    case self.command
    #when create_table: nothing to be done.
    when :rename_table
      migration_text = migration_text + ", :" + self.options[:new_name].tableize
      return migration_text
    when :drop_table
      return migration_text
    when :add_column
      migration_text = migration_text + ", :#{self.options[:column_name]}, :#{self.options[:column_type]}"       
    when :rename_column
      migration_text = migration_text + ", :#{self.options[:column_name]}, :#{self.options[:new_name]}"
      return migration_text
    when :change_column
      if self.options.has_key?(:new_type)
        migration_text = migration_text + ", :#{self.options[:column_name]}, :#{self.options[:new_type]}"
      else
        migration_text = migration_text + ", :#{self.options[:column_name]}, :#{self.options[:column_type]}"
      end
    when :remove_column 
      migration_text = migration_text + ", :#{self.options[:column_name]}"
      return migration_text
    when :add_index
      migration_text = migration_text + ", :#{self.options[:column_name]}"
      if self.options.has_key?(:index_name)
        migration_text = migration_text + ", :name => '#{self.options[:index_name]}'" 
        self.options.delete(:index_name)    
      end
    when :remove_index
      migration_text = migration_text + ", :#{self.options[:column_name]}"
      return migration_text
    end
    #:create_table, :add_column, :change_column or :add_index
    #may have additional options
    self.options.delete(:column_name) if self.options.key?(:column_name)
    self.options.delete(:column_type) if self.options.key?(:column_type)
    self.options.delete(:new_name) if self.options.key?(:new_name)
    self.options.delete(:new_type) if self.options.key?(:new_type)
    self.options.keys.each do |key|
        migration_text = migration_text + ", :" + key.to_s + " => #{self.options[key]}" if ValidOptions.include?(key)
    end
    migration_text
  end
  
  def expect_valid_self
    unless self.valid?
      raise "Error: cannot write migration for invalid migration command '#{self.command}' with options: '#{self.options}'"
    end
  end
  
end