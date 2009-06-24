Feature: department_test
  In order to manage departments
  As a superuser admin
  I want to be able to create and manage departments

  Background:
    Given I am "Albus Dumbledore"
    And I am on the department settings page

  Scenario: Shifts settings: Start and end times
    When I

  Scenario: Shifts settings: Grace Period
    Given I have a time_slot in "TTO", from "12/25/2009 5pm" to "12/25/2009 7pm"
    And "Harry Potter" has a scheduled shift, in "TTO", from "12/25/2009 5pm" to "12/25/2009 7pm" and signed in at "12/25/2009 5:10pm"
    When I fill in "Grace Period" with "11"
    And I press "Save Settings"
    Then that report is not late

    When I fill in "Grace Period" with "7"
    And I press "Save Settings"
    Then that report is late

    #    self.signed_in? && (self.report.start - self.start > 7)

#  Scenario: Shifts settings: Time increments
#LDAP
#  host name , port #, search base (str), mappings from LDAP field to first_name and last_name (given_name and sn)
#    remove LDAP?
  Scenario: Shifts settings: Editable Reports

  Scenario: Payform settings: Reminder email text and times

  Scenario: Payform settings: Weeks before Admin view warning

  Scenario: Payform settings: Min Length for Item description

  Scenario: Payform settings: Min Length for edit and deletion of reason

  Scenario: Payform settings: Punchclock

  Scenario: Payform settings: Disabled Categories vs Miscellaneous

  Scenario:

