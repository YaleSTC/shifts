Feature: user_test
  In order to create a roster
  As an regular user
  I want to create and manage users

  Background:
    Given the user "Albus Dumbledore" has permissions "Hogwarts dept admin"
    And I am "Albus Dumbledore"
    And I am on the list of users

  Scenario: Mass add users
    Given I have no users
    When I follow "Mass Add"
    And I fill in "logins" with "wy59 brs35 alb64 aje29"
    And I press "Submit"
    Then I should see "New users created"
    And I should have 4 users

