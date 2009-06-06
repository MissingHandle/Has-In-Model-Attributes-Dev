Feature: Keep model attributes in the model file.
  In order to Avoid headaches wondering what my database looks like
  As a rails programmer,
  I want my model's attributes to be clearly defined within my models,
  and want database migrations to be handled seamlessly without me thinking about them.
  
  Scenario: A new attribute is defined in the model
    Given I am within a rails model named MyModel
	And MyModel acts_as_attributable
	And MyModel includes an attribute definition using "define_attribute"
	And this attribute is not in the database
	When I run rake:attributes
	Then a rails migration file should be created
	And the rails migration file should include an up definition for the defined attribute
	And the rails migration file should include a down definition for the defined attribute
	And the rails migration should be run
	And the rails migration should be successful
	And I should see "1 attribute for MyModel successfully defined."
	
 Scenario: An already existing attribute is defined in the model
 	Given I am within a rails model named MyModel
	And MyModel acts_as_attributable
	And MyModel includes an attribute definition using "define_attribute"
	And this attribute is already present in the database
	When I run rake:attributes
	Then nothing should be done
	And I should see "1 already existing attribute for MyModel"

