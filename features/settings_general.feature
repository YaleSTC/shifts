@configs
@cw
@passing
Feature: Settings
  In order to manage Settings
  As an admin
  I want settings to be created when I create the objects they configure

  Background:
    Given I am "Albus Dumbledore"

  Scenario: Department settings should be created when a new department is created
    Given the user "Albus Dumbledore" is a superuser
    And I am on the list of departments
    And I follow "New Department"
    And I fill in "Name" with "Outer Space"
    And I press "Create"
    Then I should see "Successfully created department"
    And I should have a department named "Outer Space"
    And the department "Outer Space" should have a department_config

  Scenario: User settings should be created when a new user is created
    Given the user "Albus Dumbledore" has permissions "Hogwarts dept admin"
    And I am "Albus Dumbledore"
    And I am on the list of users
    When I follow "Add A New User"
    And I fill in "Login" with "ll66"
    And I fill in "First Name" with "Luna"
    And I fill in "Last Name" with "Lovegood"
    And I fill in "Email" with "ll66@hogwarts.edu"
    And I select "CAS" from "user_auth_type"
    And I press "Create"
    Then I should see "Successfully created user."

    And I should have a user named "Luna Lovegood"
    And "Luna Lovegood" should have 1 user_config

