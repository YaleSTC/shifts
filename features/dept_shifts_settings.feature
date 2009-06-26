Feature: department_test
  In order to manage departments
  As a superuser admin
  I want to be able to create and manage departments

  Background:
    Given I am "Albus Dumbledore"
    And I am on the department settings page
    And there is a scheduled shift:
        | start_time     | end_time       | location     | user         |
        | 12/25/2009 5pm | 12/25/2009 7pm | Diagon Alley | Harry Potter |
    And "Harry Potter" signs in at "12/25/2009 5:10pm"

  Scenario: Shifts settings: Start and end times

  Scenario: Shifts settings: Grace Period
    When I fill in "Grace Period" with "11"
    And I press "Save Settings"
    Then that_shift should not be late

    When I fill in "Grace Period" with "7"
    And I press "Save Settings"
    Then that_shift should be late

  Scenario: Shifts settings: Time increments
    When I choose "60" from "Time Increments"
    And I go to the shifts page
    And I follow "Time Slots"
    Then I should be able to select "1"

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

 Scenario: Shifts settings: Editable Reports off
    When I uncheck "Editable Reports"
    And I press "Save Settings"

    And I am "Harry Potter"
    And I comment in that_report "I hate my job."
    And I am on that_shift page
    And I follow "View Report"
    Then I should see "I hate my job."
    And I should not see "edit"

