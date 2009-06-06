desc "diffs models which use 'has_in_model_attributes' with the database's schema.\n
generates and runs migrations so that the db matches definitions in the model"

namespace :hima do
  task :attributes => :environment do
    require File.join(File.dirname(__FILE__), "../lib/hima_attribute.rb")
    require File.join(File.dirname(__FILE__), "../lib/hima_model.rb")
    require File.join(File.dirname(__FILE__), "../lib/hima_db_delta.rb")
    require File.join(File.dirname(__FILE__), "../lib/hima_db_migration.rb")
    require File.join(File.dirname(__FILE__), "../lib/hima_migration.rb")
    HimaMigration.do_migrations
    #run "rake db:migrate" ?
  end
  
  task :wipe_clean do #|model_name| model_name as argument?
    #should basically run the reverse of the 'has_in_model_attributes' method
  end
end  