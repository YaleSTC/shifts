@settings

Feature: User settings
  In order to manage user settings
  As a regular user
  I want manage my own settings

  Background:
    Given the user "Harry Potter" has permissions "Inside of Hogwarts view, Inside of Hogwarts signup"
    And I am "Harry Potter"
    And I am on the user settings page

  Scenario: Changing the default department
    Then I should see "Default department"
    And I should see "Hogwarts"
    When I select "Hogwarts" from "Default department"
    And I press "Submit"
    Then I should see "Successfully updated user config."
    When I go to the homepage
    Then the page should indicate that I am in the department "Hogwarts"
    When I go to the user settings page
    And I select "Outer Space" from "Default department"
    And I press "Submit"
    Then I should see "Successfully updated user config."
    When I go to the homepage
    Then the page should indicate that I am in the department "Outer Space"

  Scenario: Changing the days displayed in shifts
#     This test will not work if you happen to run it
#     for the first day of the shift cycle (sunday if weekly)
    Given I had a shift yesterday
    And "Hermione Granger" has a shift tomorrow
    And today is not Sunday

    When I select "Whole pay period" from "View week"
    And I press "Submit"
    Then I should see "Successfully updated user config."
    When I go to shifts for this week
    Then I should see all the days of the week
    And I should see "Harry Potter"
    And I should see "Hermione Granger"

    When I go to the user settings page
    And I select "Remainder of period" from "View week"
    And I press "Submit"
    Then I should see "Successfully updated user config."
    When I go to shifts for this week
    Then I should see all the days of the week
    And I should not see "Harry Potter"
    And I should see "Hermione Granger"

    When I go to the user settings page
    And I select "Just the current day" from "View Week"
    And I press "Submit"
    Then I should see "Successfully updated user config."
    When I go to shifts for this week
    Then I should not see all the days of the week
    And I should not see "Harry Potter"
    And I should not see "Hermione Granger"

  Scenario: What LocGroups to display on schedule view
    Given I have a LocGroup named "Inside of Hogwarts" with location "Potions"
    And I have a LocGroup named "Inside of Hogwarts" with location "Common Room"
    And I go to the user settings page
    Then I should see "Inside of Hogwarts"
    When I check "Inside of Hogwarts"
    And I press "Submit"
    Then I should see "Successfully updated user config."
    When I go to shifts
    Then I should see "Potions"
    And I should not see "Common Room"

    When I go to the user settings page
    And I check "Gryffindor"
    And I uncheck "Classrooms"
    And I press "Submit"
    Then I should see "Successfully updated user config."
    When I go to shifts
    Then I should see "Common Room"
    And I should not see "Potions"