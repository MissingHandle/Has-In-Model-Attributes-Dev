# The Has In Model Attributes (Hima) Plugin
# Conceived of by Gabe Saravia
# Authored By: Gabe Saravia
#
#

# require "config/environment"
# 
MODEL_DIR   = File.join(RAILS_ROOT, "app/models")

module GabrielSaravia #:nodoc:
  module Has #:nodoc:
    module InModelAttributes #:nodoc:
    
      def self.included(base)
        base.class_eval do
          extend(ClassMethods)
          class_inheritable_accessor :in_model_attributes
          self.in_model_attributes = false          
        end
      end

      module ClassMethods
        
        def has_in_model_attributes
          self.class_eval do
            extend(SingletonClassMethods)
            self.in_model_attributes = true
            class_inheritable_accessor :hima_model_representation
            self.hima_model_representation = HimaModel.new
            self.hima_model_representation.name = self.name
          end
        end
        
      end
    
      module SingletonClassMethods
        
        require 'hima_attribute'
        require 'hima_model'
  
        def define_attribute(*args)
          a = HimaAttribute.new
          a.name = args[0].to_sym
          a.type = args[1].to_sym
          a.options = args.last if args.last.is_a?(Hash)
          self.hima_model_representation.add(a)
        end
        
      end
    
    end
  end
end
