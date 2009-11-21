class MyModel < ActiveRecord::Base
  
  has_in_model_attributes
  
  #the standard trifecta
  define_attribute  :id, :integer
  define_attribute  :created_at, :datetime
  define_attribute  :updated_at, :datetime
  
  #your own attributes
  define_attribute  :name, :string, :limit => 40
  
end
