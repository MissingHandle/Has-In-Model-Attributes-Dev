# require 'hima_attribute.rb'
# require 'hima_model.rb'
# require 'hima_db_delta.rb'
# require 'hima_db_migration.rb'

#this module uses code borrowed from 
#Dave Thomas' "AnnotateModels" Plugin.
module HimaRunner
    
  MODEL_DIR = "#{RAILS_ROOT}/app/models/"
  
  PREFIX = "== Your In Model Attributes"
  SCHEMA_LINE = "Current Schema Version:"

  #Returns a list of all model files 
  #in the app/models directory. (from "AnnotateModels")
  def self.get_model_filenames
    models = []
    Dir.chdir(MODEL_DIR) do 
      models = Dir["**/*.rb"]
    end
    models
  end
  
  #gets the current make up of the database table 
  #by using ActiveRecord's column methods
  #returns a HimaModel object 
  def self.get_db_schema(klass)
    model = HimaModel.new
    model.name = "#{klass}"
    klass.column_names.each do |name|
      a = HimaAttribute.new
      a.name = name.to_sym
      a.type = klass.columns_hash[name].type
      #a.options not sure how to do this yet.
      model.add(a)
    end
    model
  end

  def self.get_hima_schema(klass)
    return false unless klass.in_model_attributes == true
    klass.hima_model_representation
  end
  
  #creates a migration file in the db/migrate directory,
  #the name is UTC timestamped a la rails conventions
  #it is named a generic 'changes_to_#{model_name}' 
  #followed by a randomly generated 6 character string to 
  #avoid naming collisions
  #returns the filehandle of the open file 
  #for possible additional operations/testing.
  def self.write_one_migration(klass_name, migration)
    timestamp = Time.new
    timestamp.utc
    time_string = timestamp.strftime("%Y%m%d%H%M%S")
    #generate a random alphanumeric string to append to the filename/class, code was googled.
      chars = ('a'..'z').to_a + (1..9).to_a
      s = (0...6).collect { chars[Kernel.rand(chars.length)] }.join
    #----
    f = File.new(File.join("#{RAILS_ROOT}/db/migrate","#{time_string}_changes_to_#{klass_name.underscore}#{s}.rb"), "w")
    f.write("class ChangesTo#{klass_name}#{s} < ActiveRecord::Migration\n\n")
    migration.write_self_to_file(f)
    f.write("end") #class   
    return f
  end
  
  #Borrowing from Dave Thomas' Annotate Models
  def self.do_migrations
    self.get_model_filenames.each do |m|
      class_name = m.sub(/\.rb$/,'').camelize
      begin
        klass = class_name.split('::').inject(Object){ |klass,part| klass.const_get(part) }
        if klass < ActiveRecord::Base && !klass.abstract_class? && klass.in_model_attributes
          puts "In #{class_name}..."
          from_model = self.get_hima_schema(klass)
          from_ar = self.get_db_schema(klass)
          migration = HimaDbMigration.new
          migration.make_self(from_model, from_ar)
          if !(migration.empty?)
            self.write_one_migration(class_name, migration)
            #Non-Existent Feature: 
            #edit_model_for_name_changes(from_model) #remove ':should_be' keys and make the name of the attribute the new name
          end
        else
          puts "Skipping #{class_name}"
        end
      rescue Exception => e
        puts "Unable to unify Schema from DB and ModelFile for #{class_name}: #{e.message}"
      end
    end
  end
  
end