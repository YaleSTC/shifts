Feature: User_test
  In order
  As an
  I want

  Scenario Mass add users
    Given I have a department named "STC"
    And I have no users
    When I go to mass add
    And I fill in "netids" with "wy59, brs35, alb64, aje29"
    And I press "Submit"
    Then I should see "New users created"
    And I should have 4 users

  Scenario Create a new user
    Given I have a department named "STC"
    And I have no users
    And I am on the list of users
    When I follow "New User"
    And I fill in "netid" with "wy59"
    And I fill in "name" with "Wei Yan"
    And I press "Create"
    Then I should see "Successfully created user"
    And I should see "Wei Yan"
    And I should see "wy59"
    And I should have 1 user

