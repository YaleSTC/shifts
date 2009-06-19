@data

Feature: data types
  In order to manage data types
  As an admin
  I want to be able to create and maintain data types

    Background:
        Given the user "John Arbuckle" has permissions "regular user, department administrator"
        And I am "John Arbuckle"

    Scenario: Create a Data type
        Given I have no data_types
        And I am on the data types page
        When I follow "Create new data type"
        And I fill in "Name" with "Ring"
        And I fill in "Description" with "The Rings of Power"
        And I fill in "Data Field Name" with "Evil"
        And I select "Radio buttons" from "Display Type"
        And I fill in "Values" with "yes, no"
        And I follow "New data field"
        And I fill in "Data Field Name" with "Metals"
        And I select "Check Box" from "Display Type"
        And I follow "New data field"
        And I fill in "Data Field Name" with "Description of type of magic"
        And I select "Text Area" from "Display Type"
        And I press "Create"
        Then I should see "New data type created."
        And I should see "Ring"
        And I should see "The Rings of Power"

    Scenario: Edit a Data type
        Given I have a data type with name "Cat", description "they're animals", for the department "Pet Store", with the following data fields
        | name              | display_type | values                                   |
        | Name              | text_field   | string                                   |
        | Color             | select_box   | Black, Orange, Yellow, White, Gray       |
        | Interests         | check_box    | Eating, Sleeping, Lasagna, Chasing Jerry |
        | Comments          | text_area    |                                          |
        | Number of lives   | text_field   | integer                                  |
        | Level of cuteness | text_field   | float                                    |

        And I have 1 data_type
        And I am on the data types page
        When I follow "Edit"
        And I fill in "Name" with "Vegetable"
        And I fill in "Description" with "Makes you strong"
        And I press "Save changes"
        Then I should see "Data type edited"
        And I should see "Vegetable"
        And I should see "Makes you strong"

   Scenario: Delete a Data type
        Given I have a data type with name "Ring of Power", description "powerful", for the department "Outer Space", with the following data fields
        | name     | display_type | values                                   |
        | Name     | text_field   | string                                   |
        | Metal    | select_box   | Gold, Silver, Copper, Brass, Iron        |
        | Powers   | check_box    | Invisibility, The Force, Flight          |
        | Comments | text_area    |                                          |
        | Number   | text_field   | integer                                  |

        And I have 1 data_type
        And I am on the data types page
        When I follow "Delete"
        And I press "Yes, please delete this"
        Then I should see "Data type deleted"
        And I should not see "Ring"
        And I should have no data_types

