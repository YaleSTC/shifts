@data

Feature: data types
  In order to manage data types
  As an admin
  I want to be able to create and maintain data types

    Background:
        Given the user "John Arbuckle" has permissions "Pet Store dept admin, Outer Space dept admin"
        And I am "John Arbuckle"

    Scenario: Create a Data type
        Given I have no data_types
        And I am on the data types page
        When I follow "New Data Type"
        And I fill in "Name" with "Ring"
        And I fill in "Description" with "The Rings of Power"
        And I fill in "data_type[data_fields_attributes][0][name]" with "Evil"
        And I select "Multiple Choice" from "Display Type"
        And I fill in "data_type[data_fields_attributes][0][values]" with "yes, no"
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

