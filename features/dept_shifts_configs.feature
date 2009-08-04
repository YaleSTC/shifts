@configs
@cw
@breaking
@wip
Feature: Shift settings
  In order to manage shift settings
  As an admin
  I want to be able to configure shift settings

  Background:
    Given I am "Albus Dumbledore"
    And the user "Albus Dumbledore" has permissions "Hogwarts dept admin, Hogwarts shifts admin"
    And the user "Harry Potter" has permissions "Outside of Hogwarts view, Outside of Hogwarts signup"
    And I am on the department settings page for the "Hogwarts" department
    Then I should see "blah blah blah"

  Scenario: Shifts settings: Start and end times
    Given I am "Albus Dumbledore"
    When I select "05:00 AM" from "department_config_schedule_start"
    And I select "07:00 AM" from "department_config_schedule_end"
    And I press "Save"
    And I go to shifts
    Then I should see "5:00"
    And I should see "6:00"
    And I should see "7:00"
    And I should not see "8:00"
    And I should not see "4:00"

  Scenario: Shifts settings: Time increments (1 hour)
    When I fill in "department_config_time_increment" with "60"
    And I press "Save"
    When I am on shifts
    And I follow "Power sign up"
    And the "shift[start(5i)]" field should contain "00"
    And the "Start" field should not contain "15"
    And the "Start" field should not contain "30"
    When I go to the shifts page
    And I follow "Time Slots"
    And the "mass_create_start_in_minute_5i" field should contain "00"
    And the "mass_create_start_in_minute_5i" field should not contain "15"
    And the "mass_create_start_in_minute_5i" field should not contain "15"

  Scenario: Shifts settings: Time increments (half hour)
    When I fill in "department_config_time_increment" with "30"
    And I press "Save"
    When I am on shifts
    And I follow "Power sign up"
    And the "Start" field should contain "00"
    And the "Start" field should not contain "15"
    And the "Start" field should contain "30"

    When I go to the shifts page
    And I follow "Time Slots"
    And the "Start" field should contain "00"
    And the "Start" field should not contain "15"
    And the "Start" field should contain "15"


  Scenario: Shifts settings: Grace Period part 1
#  (in 2 parts because webrat interacts buggily with global vars)
    Given there is a scheduled shift:
        | start_time     | end_time       | location     | user         |
        | 12/25/2009 5pm | 12/25/2009 7pm | Diagon Alley | Harry Potter |
    And "Harry Potter" signs in at "12/25/2009 5:10pm"
    When I fill in "department_config_grace_period" with "11"
    And I press "Save"
    Then that_shift should not be late

  Scenario: Shifts settings: Grace Period part 2
    Given there is a scheduled shift:
        | start_time     | end_time       | location     | user         |
        | 12/25/2009 5pm | 12/25/2009 7pm | Diagon Alley | Harry Potter |
    And "Harry Potter" signs in at "12/25/2009 5:10pm"
    When I fill in "department_config_grace_period" with "1"
    And I press "Save"
    Then that_shift should be late

