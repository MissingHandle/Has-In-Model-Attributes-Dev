HasInModelAttributes - 0.2.0
====================

This is now only here for nostalgic purposes - 
this is the first code I wrote that I open sourced. (What what!)

HasInModelAttributes (HIMA) changes the behavior of the model with which it is used such that a model's attributes are defined in the model file itself and significantly automates the process of creating and running database migrations.  

HIMA extends ActiveRecord with one function, "define_attribute" and adds one rake task, "rake hima:attributes".  The "define attribute" function is used to define attributes in the model file.  The rake task goes through the process of 'diff'ing your model file and your current database schema.  It then writes a migration file to bring the db schema in line with what you have specified in your file.

If you use HIMA with one of your models, you MUST specify your attributes in the model file, as the contents of the model file are seen as gospel, and the task "rake hima:attributes" will write a migration file for you to match your model definition.  While such a process may sound restricting, HIMA should free you from thinking about your database and make your programming life easier.  Refer to the examples below to see how to use HIMA:


Examples
=======

1 - ATTRIBUTES IN THE MODEL THAT ARE NOT IN THE DATABASE
 Suppose Your Model only has two attributes, name, which is a string and some_stupid_number, an integer.  Using HIMA, your model should look like this:

class MyModel < ActiveRecord::Base

  has_in_model_attributes

  define_attribute :name, :string
  define_attribute :some_stupid_number, :integer

end

when you run "rake hima:attributes", the structure of the database table for MyModel will be checked, using whatever table name has been set or is assumed by rails naming conventions.  Then a "diff" of these two: what you have in your model, and what is in the database is performed, and if there is any difference, then a rails migration file will be created.  

In the above case, supposing the table has been created, but without any attributes, then HIMA will see that your model defines an attribute that is not in the database, so the migration will look like this:

def self.up
  add_column :my_model, :name, :string
  add_column :my_model, :some_stupid_number, :integer
end

def self.down
  remove_column :my_model, :name
  remove_column :my_model, :some_stupid_number
end


2 - MODEL FILE AND DATABASE ARE THE SAME
Following from above, suppose you then, just for the heck of it, decide to run the rake hima:attributes task again, with nothing being different.  In this case, no migration file will be generated and you will be told "nothing to be done for all HIMA Models"

3 - AN ATTRIBUTE IN THE DATABASE IS NOT IN THE MODEL FILE
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

4 - ATTRIBUTE NAME CHANGES

Attribute name changes are not currently handled.

5 - TABLE NAME CHANGES

Table name changes are not currently handled.

6 - TO DO:
* Rake:attributes should check for pending migrations and fail if there are any.
* :id, :updated_at, and :created_at should be specially handled.
* Attribute name changes should reach into the model file, eliminate ':should_be' key, and correctly rename the attribute to prevent future mistakes.
* Handle Table Name Changes Somehow.


Copyright (c) 2009 Gabriel Saravia, released under the MIT license
