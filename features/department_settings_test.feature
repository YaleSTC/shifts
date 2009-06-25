Feature: department_test
  In order to manage departments
  As a superuser admin
  I want to be able to create and manage departments

  Background:
    Given I am "Albus Dumbledore"
#    And I am on the department settings page

  Scenario: Shifts settings: Start and end times

  Scenario: Shifts settings: Grace Period
    Given there is a scheduled shift:
        | start_time     | end_time       | location     | user         |
        | 12/25/2009 5pm | 12/25/2009 7pm | Diagon Alley | Harry Potter |
    And "Harry Potter" signs in at "12/25/2009 5:10pm"
#    When I fill in "Grace Period" with "11"
#    And I press "Save Settings"
#    Then that_shift should not be late

#    When I fill in "Grace Period" with "7"
#    And I press "Save Settings"
    Then that_shift should be late

#  Scenario: Shifts settings: Time increments
#LDAP
#  host name , port #, search base (str), mappings from LDAP field to first_name and last_name (given_name and sn)
#    remove LDAP?
  Scenario: Shifts settings: Editable Reports on
    Given there is a scheduled shift:
        | start_time     | end_time       | location | user         |
        | 12/25/2009 5pm | 12/25/2009 7pm | Diagon Alley | Harry Potter |
    And "Harry Potter" signs in at "12/25/2009 5:10pm"
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
    Given there is a scheduled shift:
        | start_time     | end_time       | location      | user         |
        | 12/25/2009 5pm | 12/25/2009 7pm |  Diagon Alley | Harry Potter |
    And "Harry Potter" signs in at "12/25/2009 5:10pm"
#    When I uncheck "Editable Reports"
#    And I press "Save Settings"

    And I am "Harry Potter"
    And I comment in that_report "I hate my job."
    And I am on that_shift page
    And I follow "View Report"
    Then I should see "I hate my job."
    And I should not see "edit"

  Scenario: Payform settings: Reminder email text and times

  Scenario: Payform settings: Weeks before Admin view warning

  Scenario: Payform settings: Min Length for Item description
    When I fill in "Minimum Length for Item description" with "7"
    And I press "Save"


  Scenario: Payform settings: Min Length for edit and deletion of reason

  Scenario: Payform settings: Punchclock

  Scenario: Payform settings: Disabled Categories vs Miscellaneous

  Scenario:

