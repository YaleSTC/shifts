@configs
@cw
@breaking
Feature: User configs
  In order to manage user settings
  As a regular user
  I want manage my own settings

  Background:
    Given I am "Harry Potter"
    And the user "Harry Potter" has permissions "Outside of Hogwarts view, Outside of Hogwarts signup, Inside of Hogwarts view"
    And I am on the user settings page
@passing
  Scenario: A New user has default settings
    When I follow "Logout"
    Given I am "Albus Dumbledore"
    And I am on the list of users
    When I follow "Add A New User"
    And I fill in "Login" with "rw12"
    And I fill in "First name" with "Ron"
    And I fill in "Last name" with "Weasley"
    And I fill in "Email" with "rw12@hogwarts.edu"
    And I select "built-in" from "user_auth_type"
    And I press "Create"
    Then I should see "Successfully created user"
    Then I should have a user named "Ron Weasley"
    Then "Ron Weasley" should have 1 user_config
@passing
  Scenario: Changing the default department
    When I select "Hogwarts" from "user_config[default_dept]"
    And I press "Submit"
    Then I should see "Successfully updated user config."
    When I follow "Logout"
    And I am "Harry Potter"
    And I go to the homepage
    Then the page should indicate that I am in the department "Hogwarts"
    When I go to the user settings page
    And I select "Pet Store" from "user_config[default_dept]"
    And I press "Submit"
    Then I should see "Successfully updated user config."
    When I follow "Logout"
    And I am "Harry Potter"
    And I go to the homepage
    Then the page should indicate that I am in the department "Pet Store"

  Scenario: Changing the days displayed in shifts
#     This test will not work if you happen to run it
#     for the first day of the shift cycle (sunday if weekly)
#     or if you run it on Friday (because the schedule is Mon-fri now) evidently
    Given "Hermione Granger" had a shift yesterday in "Diagon Alley"
    And the user "Hermione Granger" has permissions "Outside of Hogwarts signup, Outside of Hogwarts view, Outside of Hogwarts admin"
    And I have a shift tomorrow in "Diagon Alley"
    Given today is not Sunday

    When I select "Whole pay period" from "View week"
    Then the "Outside of Hogwarts" checkbox should be checked
    And I press "Submit"
    Then I should see "Successfully updated user config."
    When I go to shifts for this week
    Then I should see all the days of the week
    And I should see "Upcoming shifts"
    And I should see "Harry Potter" on the schedule
    And I should see "Hermione Granger" on the schedule
    And I should see "tomorrow" on the schedule
    And I should see "yesterday" on the schedule

    When I go to the user settings page
    And I select "Remainder of period" from "View week"
    And I press "Submit"
    Then I should see "Successfully updated user config."
    When I go to shifts for this week
    Then I should see "tomorrow" on the schedule
    And I should not see "yesterday" on the schedule
    And I should not see "Harry Potter" on the schedule
    And I should see "Hermione Granger" on the schedule

    When I go to the user settings page
    And I select "Just the current day" from "View Week"
    And I press "Submit"
    Then I should see "Successfully updated user config."
    When I go to shifts for this week
    Then I should not see "yesterday" on the schedule
    And I should not see "tomorrow" on the schedule
    And I should not see "Harry Potter" on the schedule
    And I should not see "Hermione Granger" on the schedule
@passing
  Scenario: What LocGroups to display on schedule view
    Given the user "Harry Potter" has permissions "Inside of Hogwarts view, Outside of Hogwarts view"
    When I go to the user settings page
    Then I should see "Inside of Hogwarts"
    When I check "Inside of Hogwarts"
    And I uncheck "Outside of Hogwarts"
    And I press "Submit"
    Then I should see "Successfully updated user config."
    When I go to shifts
    Then I should see "Potions"
    And I should not see "Diagon Alley"

    When I go to the user settings page
    And I check "Outside of Hogwarts"
    And I uncheck "Inside of Hogwarts"
    And I press "Submit"
    Then I should see "Successfully updated user config."
    When I go to shifts
    Then I should see "Diagon Alley"
    And I should not see "Potions"

