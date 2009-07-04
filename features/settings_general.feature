@settings

Feature: Settings
  In order to manage Settings
  As an admin
  I want settings to be created when I create the objects they configure

  Background:
    Given I am "Albus Dumbledore"

  Scenario: Department settings should be created when a new department is created
#    Given the user "Albus Dumbledore" is a superuser
    And I am on the list of departments
    And I follow "New Department"
    And I fill in "Name" with "School"
    And I press "Create"
    Then I should see "Successfully created department"
    And I should have a department named "School"
    And the department "School" should have a department config


  Scenario: User settings should be created when a new user is created
    Given the user "Albus Dumbledore" has permission "Hogwarts dept admin"
    And I am on the list of users
    When I follow "Add A New User"
    And I fill in "Login" with "rw12"
    And I fill in "First name" with "Ron"
    And I fill in "Last name" with "Weasley"
    And I fill in "Email" with "rw12@hogwarts.edu"
    And I select "CAS" from "Login type"
    And I press "Create"
    Then I should see "Successfully created user"
    And I should have a user named "Ron Weasley"
    And "Ron Weasley" should have 1 user_config

