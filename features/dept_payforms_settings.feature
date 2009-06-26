Feature: department_test
  In order to manage departments
  As a superuser admin
  I want to be able to create and manage departments

  Background:
    Given I am "Albus Dumbledore"
    And I am on the department settings page

  Scenario: Payform settings: Reminder email text and times
    Given I have the following payforms:
      | date       | department | user_first | user_last      | submitted | approved |printed|
      | 2009-06-13 | Hogwarts   | Harry      | Potter         | nil       | nil      | nil   |
      | 2009-06-06 | Hogwarts   | Harry      | Potter         | true      | nil      | nil   |
      | 2009-05-09 | Hogwarts   | Harry      | Potter         | true      | true     | nil   |
      | 2009-05-23 | Hogwarts   | Hermione   | Granger        | true      | true     | nil   |
      | 2009-05-16 | Hogwarts   | Hermione   | Granger        | true      | true     | true  |


  Scenario: Payform settings: Weeks before Admin view warning


  Scenario: Payform settings: Min Length for Item description
    When I fill in "Minimum Length for Item description" with "7"
    And I press "Save"


  Scenario: Payform settings: Min Length for edit and deletion of reason


  Scenario: Payform settings: Punchclock


  Scenario: Payform settings: Disabled Categories vs Miscellaneous

