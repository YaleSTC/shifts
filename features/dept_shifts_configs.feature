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

@passed
  Scenario: Shifts settings: Start and end times
    When I select "05:00 AM" from "department_config_schedule_start"
    And I select "07:00 AM" from "department_config_schedule_end"
    And I press "Submit"
    And I go to the shifts page
    Then I should see "5:00"
    And I should see "6:00"
    And I should see "7:00"
    And I should not see "8:00"
    And I should not see "4:00"

  Scenario Outline: Shifts settings: Time increments
    When I fill in "department_config_time_increment" with "<time increment>"
    And I press "Submit"
    When I am on the shifts page
    And I follow "Power sign up"
    Then I should <1:00>be able to select "1:00" as a time
    And I should <1:15>be able to select "01:15" as a time
    And I should <1:30>be able to select "1:30" as a time

    When I go to the shifts page
    And I follow "Time Slots"
    Then I should <1:00>be able to select "01:00" as a time
    And I should <1:15>be able to select "01:15" as a time
    And I should <1:30>be able to select "01:30" as a time

      Examples:
      | time increment | 1:00 | 1:15 | 1:30 |
      | 60             |      | not  | not  |
      | 30             |      | not  |      |
      | 15             |      |      |      |

  Scenario: Shifts settings: Grace Period
    When I fill in "department_config_grace_period" with "11"
    And I press "Submit"
    Then that_shift should not be late

    When I fill in "department_config_grace_period" with "7"
    And I press "Submit"
    Then that_shift should be late

