Feature: user_test
  In order to create a roster
  As an regular user
  I want to create and manage users

  Scenario: Mass add users
    Given I have a department named "STC"
    And I have no users
    And I am on the list of users
    When I follow "Mass Add"
    And I fill in "logins" with "wy59 brs35 alb64 aje29"
    And I press "Submit"
    Then I should see "New users created"
    And I should have 4 users

  Scenario: Create a new user
    Given I have a department named "STC"
    And I have no users
    And I am on the list of users
    When I follow "New"
    And I fill in "login" with "wy59"
    And I fill in "name" with "Wei Yan"
    And I press "Create"
    Then I should see "Successfully created user"
    And I should see "Wei Yan"
    And I should see "wy59"
    And I should have 1 user

