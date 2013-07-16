@data
@cw
@breaking
#@passing
@ajax
Feature: data types
  In order to manage data types
  As an admin
  I want to be able to create and maintain data types

    Background:
        Given the user "John Arbuckle" has permissions "Pet Store dept admin"
        And I am "John Arbuckle"

    Scenario: Create a Data type
        Given I have no data_types
        And I am on the data types page
        When I follow "New Data Type"
        And I fill in "Name" with "Ring"
        And I fill in "Description" with "The Rings of Power"
        And I follow "Add a data field"
        And I press "Submit"
        Then I should see "Successfully created data type."

        And I should see "Add fields"
        When I fill in "Name" with "Evil"
        And I select "Multiple Choice" from "Display type"
        And I fill in "Values" with "yes, no"
        And I press "Save and add another field"
        Then I should see "Successfully created data field."
        When I fill in "Name" with "Metals"
        And I select "Check Boxes" from "Display Type"
        And I fill in "Values" with "Gold, Silver, Bronze"
        And I press "Save and add another field"
        Then I should see "Successfully created data field."
        When I fill in "Name" with "Description of type of magic"
        And I select "Text Field" from "Display Type"
        And I press "Save and finish"
        Then I should see "Successfully created data field."
        And I should see "Ring"
        And I should see "The Rings of Power"
        And I should see "Evil"
        And I should see "Metals"
        And I should see "Description of type of magic"

        And I should see "New Data Object"
        When I fill in "Name" with "the one ring"
        And I fill in "Description" with "to rule them all"
        And I check "Jurassic Park Pets"
        And I press "Save and finish"

        Then I should see "Successfully created data object."
        And I should see "the one ring"

    Scenario: Edit a Data type
        Given I have a data type with name "Cat", description "they're animals", for the department "Pet Store", with the following data fields
        | name              | display_type | values                                   |
        | Name              | text_field   | string                                   |
        | Color             | select_box   | Black, Orange, Yellow, White, Gray       |
        | Interests         | check_box    | Eating, Sleeping, Lasagna, Chasing Jerry |
        | Comments          | text_area    |                                          |
        | Number of lives   | text_field   | integer                                  |
        | Level of cuteness | text_field   | float                                    |

        And I am on the data types page
        When I follow "Edit"
        And I fill in "Name" with "Vegetable"
        And I fill in "Description" with "Makes you strong"
        And I press "Submit"
        Then I should see "Successfully updated data type."
        And I should see "Vegetable"
        And I should see "Makes you strong"

   Scenario: Delete a Data type
        Given I have a data type with name "Ring of Power", description "powerful", for the department "Pet Store", with the following data fields
        | name     | display_type | values                                   |
        | Name     | text_field   | string                                   |
        | Metal    | select_box   | Gold, Silver, Copper, Brass, Iron        |
        | Powers   | check_box    | Invisibility, The Force, Flight          |
        | Comments | text_area    |                                          |
        | Number   | text_field   | integer                                  |

        And I am on the data types page
        Then I should see "Destroy"
        When I follow "Destroy"
#        And I press "Yes, please delete this" Does not work b/c of AJAX
        Then I should see "Successfully destroyed data type."
        And I should not see "Ring"
        And I should have no data_types

