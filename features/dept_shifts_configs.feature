@configs
@cw
Feature: Shift settings
  In order to manage shift settings
  As an admin
  I want to be able to configure shift settings

  Background:
    Given I am "Albus Dumbledore"
    And the user "Albus Dumbledore" has permissions "Hogwarts dept admin, Hogwarts shifts admin"
    And the user "Harry Potter" has permissions "Outside of Hogwarts view, Outside of Hogwarts signup"
    And I am on the department settings page for the "Hogwarts" department
    And there is a scheduled shift:
        | start_time     | end_time       | location     | user         |
        | 12/25/2009 5pm | 12/25/2009 7pm | Diagon Alley | Harry Potter |
    And "Harry Potter" signs in at "12/25/2009 5:10pm"

  Scenario: Shifts settings: Start and end times
    When I select "05:00AM" from "Schedule view start time:"
    And I select "07:00AM" from "Schedule view end time:"
    And I go to the shifts page
    Then I should see "5:00"
    And I should see "6:00"
    And I should see "7:00"
    And I should not see "8:00"
    And I should not see "4:00"
    And I should not see "Harry Potter"

  Scenario Outline: Shifts settings: Time increments
    When I select "<time increment>" from "Time Increments"
    When I am on the shifts page
    And I follow "Time Slots"
    Then I should <1:00>be able to select "01:00" as a time
    And I should <1:15>be able to select "01:15" as a time
    And I should <1:30>be able to select "01:30" as a time

    When I go to the shifts page
    And I follow "Power sign up"
    Then I should <1:00>be able to select "1:00" as a time
    And I should <1:15>be able to select "01:15" as a time
    And I should <1:30>be able to select "1:30" as a time

      Examples:
      | time increment | 1:00 | 1:15 | 1:30 |
      | 60             |      | not  | not  |
      | 30             |      | not  |      |
      | 15             |      |      |      |

  Scenario: Shifts settings: Grace Period
    When I fill in "department_config_grace_period" with "11"
    And I press "Save settings"
    Then that_shift should not be late

    When I fill in "department_config_grace_period" with "7"
    And I press "Save settings"
    Then that_shift should be late

  Scenario: Shifts settings: Editable Reports off
    When I uncheck "Editable Reports"
    And I press "Save settings"
    And I follow "Logout"

    And I am "Harry Potter"
    And I comment in that_report "I hate my job."
    And I am on that_shift page
    And I follow "View Report"
    Then I should see "I hate my job."
    And I should not see "edit"

  Scenario: Shifts settings: Editable Reports on
    When I check "department_config_edit_report"
    And I press "Save settings"
    And I follow "Logout"
    And I am "Harry Potter"
    And I comment in that_report "I hate my job."
    And I am on that_shift page
    And I follow "View Report"
    Then I should see "I hate my job."
    And I should see "edit"

    When I follow "edit"
    And I fill in "comment" with "I love my job."
    And I press "Save"
    Then I should see "I love my job."
    And I should not see "I hate my job."
    And I follow "Logout"

    Given I am "Albus Dumbledore"
    And I am on the shifts page
    And I follow "Harry Potter"
    Then I should see "I love my job."
    And I should see "I hate my job."

