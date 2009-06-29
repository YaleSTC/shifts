@data

Feature: data object
  In order to manage data objects
  As an admin
  I want to be able to create and maintain data objects

    Background:
      Given the user "John Arbuckle" has permissions "Pet Store dept admin"
      And I am "John Arbuckle"
      And I have locations "Cat Aisle, Dog Aisle, Checkout" in location group "Jurassic Park Pets" for the department "Pet Store"
      And I have a data type with name "Cat", description "they're animals", for the department "Pet Store", with the following data fields
        | name              | display_type | values                                   |
        | Name              | text_field   | string                                   |
        | Color             | select_box   | Black, Orange, Yellow, White, Gray       |
        | Interests         | check_box    | Eating, Sleeping, Lasagna, Chasing Jerry |
        | Comments          | text_area    |                                          |
        | Number of lives   | text_field   | integer                                  |
        | Level of cuteness | text_field   | float                                    |
      And I am on the data objects page

    Scenario: Creating data objects!
      Given I have no data_objects
      When I follow "New Data Object"
      And I select "Cat" from "data_object[data_type_id]"
      And I fill in "Name" with "Garfield"
      And I fill in "Description" with "he hates Mondays"
      And I check "Cats Aisle"
      And I check "Checkout"
      And I press "Create"
      Then I should have 1 data_object
      And I should see "New cat created"
      And I should see "Name: Garfield"
      And I should see "Description: he hates Mondays"
      And I should see "Locations: Cats aisle, Checkout"

    Scenario: Editing data objects
      Given I have a data object of data_type "Cat", named "Garfield", description "he hates Mondays", in location "Cat Aisle"
      When I follow "Edit"
      And I select "Cat" from "Data type"
      And I fill in "Name" with "Crookshanks"
      And I fill in "Description" with "Hermione's cat"
      And I uncheck "Cat Aisle"
      And I check "Dog Aisle"
      And I press "Edit"
      Then I should have 1 data_object
      And I should see "Cat edited"
      And I should see "Name: Crookshanks"
      And I should see "Description: Hermione's cat"
      And I should see "Locations: Dog Aisle, Checkout"

    Scenario: Deleting data objects
      Given I have a data object of data_type "Cat", named "Garfield", description "he hates Mondays", in location "Cat Aisle"
      When I follow "Destroy"
#      And I press "Yes, I am sure" again AJAX prevents this step
      Then I should have no data_objects
      And I should not see "Garfield"
      And I should not see "he hates Mondays"

