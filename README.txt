HasInModelAttributes - 0.0.1
====================

(**this readme is meant do describe the finished version of Hima, for now it just describes the way Hima *should* work...not necessarily the way it currently does, although much of what is written here does seem to work.)

ActiveRecord Objects do not specify their attributes in the model file, instead inferring them by inspecting the database table.  While this a powerful feature (and was necessary for the creation of this plugin) from a design standpoint, i think it better to have a model's attributes specified within the model itself.  Doing so could result in even greater abstraction from the database, DRYer code, and a better coding experience.

In the interest of these three goals, HasInModelAttributes (HIMA) changes the behavior of the model with which it is used such that a model's attributes are defined in the model file itself and significantly automates the process of creating and running database migrations.  

HIMA extends ActiveRecord with one function, "define_attribute" and adds one rake task, "rake hima:attributes"

If you use HIMA with one of your models, you MUST specify your attributes in the model file, as the contents of the model file are seen as gospel, and the task "rake hima:attributes" will write a migration file for you to match your model definition.

The last paragraph may sound restricting, but in actuality, HIMA should free you from a large amount of thinking about your database and make your programming life easier.  Refer to the examples below to see how to use HIMA:


Examples
=======

EXAMPLE 1: An Attribute in your Model is Not In The Database
1) Suppose Your Model only has two attribues, name, which is a string and some_stupid_number, an integer.  Using HIMA, your model should look like this:

class MyModel < ActiveRecord::Base

  has_in_model_attributes

  define_attribute :name, :string
  define_attribute :some_stupid_number, :integer

end

when you run "rake hima:attributes", HIMA checks (first) that there are no pending migrations (if there are then it fails). (<- It doesn't do this yet..watch out!)

 Then, it checks the structure of the database table for MyModel, using whatever table name has been set or is assumed by rails naming conventions.  It then (basically) creates a "diff" of these two: what you have in your model, and what is in the database.  

If there is any difference, then a rails migration file will be created.  In the above case, supposing you have not yet run a migration for your attributes, HIMA will see that your model defines an attribute that is not in the database, so the migration will look like this:

def self.up
  add_column :my_model, :name, :string
  add_column :my_model, :some_stupid_number, :integer
end

def self.down
  remove_column :my_model, :name
  remove_column :my_model, :some_stupid_number
end


EXAMPLE 2: Model File and Database Are The Same
Following from above, suppose you then, just for the heck of it, decide to run the rake hima:attributes task again, with nothing being different.  In this case, no migration file will be generated and you will be told "nothing to be done for all HIMA Models"

EXAMPLE 3: An Attribute In Your Database is Not In The Model File
suppose you then decide that the attribute "some_stupid_number" is pretty stupid, and you don't know why you put it there in the first place.  You can then simply delete the line from your model file, making it look like this:

class MyModel < ActiveRecord::Base

  has_in_model_attributes

  define_attribute :name, :string

end

now, when you run "rake hima_attributes", HIMA will look at the difference between your model and the database, see that your database has an 'extra' attribute and create a migration to delete it:

def self.up
  remove_column :my_model, :some_stupid_number
end

def self.down
  add_column :my model, :some_stupid_number
end

EXAMPLE 4: Attribute Name Changes

let's now say that you want to change the name of the "name" attribute to a "new_name" this can be done by using one of the ":should_be" option as follows:

class MyModel < ActiveRecord::Base

  has_in_model_attributes

  define_attribute :name, :string, :should_be => :new_name

end

now, when you run "rake hima_attributes" it will generate and run the following migration

def self.up
  rename_column :my_model, :name, :new_name
end

def self.down
  rename_column :my_model, :new_name, :name
end

AND HIMA will also reach inside your model attribute definition and change it so that it looks like this:

class MyModel < ActiveRecord::Base

  has_in_model_attributes

  define_attribute :new_name, :string

end


Conclusion:
Those are all the examples I have for you for now...enjoy!

Copyright (c) 2009 Gabriel Saravia, released under the MIT license