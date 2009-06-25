Feature: data types
  In order to manage data types
  As an admin
  I want to be able to create and maintain data types

  Scenario: Creating a data type
    Given I have no data_types
    And I am on the list of data_types
    When I follow "New"
    And I fill in "Name" with "Food"
    And I fill in "Description" with "delicious and healthy"
    And I select "Text box" from "Display type"
    And I fill in

