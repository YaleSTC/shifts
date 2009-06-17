Feature: User settings
  In order to manage user settings
  As a regular user
  I want manage my own settings

  Background:
    Given I am "Harry Potter"
    And I am on the user settings page

  Scenario: Changing the default department
    When I select "Hogwarts" from "Default department"
    And I press "Submit"
    And I go to the home page
    Then the page should indicate that I am in the department "Hogwarts"
    When I go to the user settings page
    And I select "Outer space" from "Default department"
    And I press "Submit"
    And I go to the home page
    Then the page should indicate that I am in the department "Outer space"

  Scenario: Changing the days displayed in shifts

