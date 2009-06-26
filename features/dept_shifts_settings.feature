Feature: department_test
  In order to manage departments
  As a superuser admin
  I want to be able to create and manage departments

  Background:
    Given I am "Albus Dumbledore"
#    And I am on the department settings page
    And there is a scheduled shift:
        | start_time     | end_time       | location     | user         |
        | 12/25/2009 5pm | 12/25/2009 7pm | Diagon Alley | Harry Potter |
    And "Harry Potter" signs in at "12/25/2009 5:10pm"

  Scenario: Shifts settings: Start and end times
    When I select "Schedule view start time:"

  Scenario: Shifts settings: Grace Period
    When I fill in "Grace Period" with "11"
    And I press "Save Settings"
    Then that_shift should not be late

    When I fill in "Grace Period" with "7"
    And I press "Save Settings"
    Then that_shift should be late

  Scenario Outline: Shifts settings: Time increments
    When I select "<time increment>" from "Time Increments"
    And I go to the shifts page
    And I follow "Time Slots"
    Then I should <1:00>be able to select "1:00" as a time
    And I should <1:15>be able to select "1:15" as a time
    And I should <1:30>be able to select "1:30" as a time

    When I go to the shifts page
    And I follow "Power signups"
    Then I should <1:00>be able to select "1:00" as a time
    And I should <1:15>be able to select "1:15" as a time
    And I should <1:30>be able to select "1:30" as a time

      Examples:
      | time increment | 1:00 | 1:15 | 1:30 |
      | 60             |      | not  | not  |
      | 30             |      | not  |      |
      | 15             |      |      |      |

  Scenario: Shifts settings: Editable Reports off
    When I uncheck "Editable Reports"
    And I press "Save Settings"

    And I am "Harry Potter"
    And I comment in that_report "I hate my job."
    And I am on that_shift page
    And I follow "View Report"
    Then I should see "I hate my job."
    And I should not see "edit"

  Scenario: Shifts settings: Editable Reports on
    When I check "Editable Reports"
    And I press "Save Settings"

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

    Given I am Dumbledore
    And I am on the payforms page

