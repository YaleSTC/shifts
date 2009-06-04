Feature: department_test
  In order to manage departments
  As a superuser admin
  I want to be able to create and manage departments
  
  Scenario: Add department
    Given I have no departments
    And I am on the list of departments
    When I follow "New Department"
    And I fill in "Name" with "STC"
    And I press "Submit"
    Then I should see "Successfully created department"
    And I should have 1 department
