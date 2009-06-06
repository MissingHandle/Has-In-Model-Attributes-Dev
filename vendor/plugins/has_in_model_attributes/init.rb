# Include hook code here
require 'has_in_model_attributes'

class ActiveRecord::Base
  include GabrielSaravia::Has::InModelAttributes
end