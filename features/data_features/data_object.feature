Feature: data object
  In order to manage data objects
  As an admin
  I want to be able to create and maintain data objects

  Background:
    Given I have a department named "Pet Store"
    And I have locations "Cats aisle, Dogs aisle, Checkout" for the department "STC"
    And I have a data type with name "Cat", description "they're animals", for the department "STC", with the following data fields
      | name              | display_type | values                                   |
      | Name              | text_field   | string                                   |
      | Color             | select_box   | Black, Orange, Yellow, White, Gray       |
      | Interests         | check_box    | Eating, Sleeping, Lasagna, Chasing Jerry |
      | Comments          | text_area    |                                          |
      | Number of lives   | text_field   | integer                                  |
      | Level of cuteness | text_field   | float                                    |

  Scenario: creating a data object
    Given I am on the data page
    When I follow "New data object"
    And I select "Cat" from "Data type"
    And I fill in "Name" with "Garfield"
    And I fill in "Description" with "he hates Mondays"
    And I check "Cats asile"
    And I check "Checkout"
    And I press "Create"
    Then I should have 1 data_object
    And I should see "New cat created"
    And I should see "Name: Garfield"
    And I should see "Description: he hates Mondays"
    And I should see "Locations: Cats asile, Checkout"

  Scenario:

