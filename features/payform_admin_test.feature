@payform
@cw
@breaking
Feature: payform admin
  In order to manage payforms
  As an admin
  I want to be able to approve, print, and perform other administrative tasks for payforms

  Background:
    Given the user "Albus Dumbledore" has permissions "Hogwarts payforms admin"
    And I am "Albus Dumbledore"
    And I have the following payforms:
      | date       | department | user_first | user_last      | submitted | approved |printed|
      | 2009-06-13 | Hogwarts   | Harry      | Potter         | nil       | nil      | nil   |
      | 2009-06-06 | Hogwarts   | Harry      | Potter         | true      | nil      | nil   |
      | 2009-05-09 | Hogwarts   | Harry      | Potter         | true      | true     | nil   |
      | 2009-05-23 | Hogwarts   | Hermione   | Granger        | true      | true     | nil   |
      | 2009-05-16 | Hogwarts   | Hermione   | Granger        | true      | true     | true  |
    And I am on the payforms page
@passing
  Scenario: Viewing payforms
    Then I should see "Harry Potter" under "User" in column 1
    And I should see "2009-06-13" under "Unsubmitted" in column 2
    And I should see "2009-06-06" under "Submitted" in column 3
    And I should see "Hermione Granger" under "User" in column 1
    And I should see "2009-05-23" under "Approved" in column 4
    And I should not see "2009-05-16"

  Scenario: Creating a Mass Job
    Given I have no payform_item_sets
    When I follow "Mass Add Jobs"
    And I select "2009-06-09" as the date
    And I select "Quidditch" from "payform_item_set[category_id]"
    And I fill in "hours" with "2"
    And I fill in "Description" with "great game!"
    And I check off "Harry Potter"
    And I check off "Hermione Granger"
    And I press "Submit"
    Then I should see "Successfully created payform item set."
    And I should have 1 payform_item_sets
    And I should see "Quidditch"
    And I should see "2009-06-09"
    And I should see "Hours"
    And I should see "2.0"
    And "Harry Potter" should have one payform item
    And "Hermione Granger" should have one payform item

  Scenario: Creating a punch clock
    Given I have no punch_clocks
    When I follow "Mass Punch Clocks"
    And I follow "Add Mass Clock"
    And I select "Quidditch" from "punch_clock[category_id]"
    And I fill in "Description" with "Starting the game"
    And I fill in "Search user" with "hp123, hg9"
    And I press "Clock Users In"
    Then I should see "Mass Punch Clock created for the following users: Harry Potter and Hermione Granger"
    When I go to Mass Punch Clocks page
    Then I should see "1 active clock"
    And I should see "Harry Potter"
    And I should see "Hermione Granger"
@passing
  Scenario: Approving payforms
    When I follow "2009-06-06"
    And I follow "Approve Payform"
    Then I should see "Successfully approved payform."
    And I should not see "not"
    When I am on the payforms page
    Then I should see "2009-06-06" under "Approved" in column 4
@passing
  Scenario: Printing Individual payforms
    When I follow "2009-05-23"
    And I follow "Print Payform"
    Then I should see "Successfully created payform set."
    And I should see "Number of payforms: 1"
    And I should see "Export CSV"
    And I follow "Print PDF"
    Then I should have a pdf with "Name: Harry Potter" in it
    Then I should have a pdf with "Login: hp123" in it
    Then I should have a pdf with "Department: Hogwarts" in it
    Then I should have a pdf with "Week Ending: May 23, 2009" in it
    Then I should have a pdf with "Total Hours: 0" in it
    Then I should have a pdf with "This payform was approved by #{@current_user} at" in it
@passing
  Scenario: Printing Sets of Payforms
   Given I have the following payform items
      | category  | user_login | hours | description        | date        |
      | Quidditch | hp123      | 1.5   | caught the snitch  | May 8, 2009 |
    When I follow "Print all approved payforms"
    Then I should see "Successfully created payform set."
    And I should see "Number of payforms: 2"
    And I should see "Export CSV"
    And I follow "Print PDF"
    Then I should have a pdf with "Name: Harry Potter" in it
    Then I should have a pdf with "Name: Hermione Granger" in it
    Then I should have a pdf with "Login: hp123" in it
    Then I should have a pdf with "Login: hg9" in it
    Then I should have a pdf with "Department: Hogwarts" in it
    Then I should have a pdf with "Week Ending: May 23, 2009" in it
    Then I should have a pdf with "Week Ending: May 9, 2009" in it
    Then I should have a pdf with "Total Hours: 0" in it
    Then I should have a pdf with "Quidditch" in it
    Then I should have a pdf with "caught the snitch" in it
    Then I should have a pdf with "Total Hours: 1.5" in it
    Then I should have a pdf with "This payform was approved by #{@current_user} at" in it
@passing
  Scenario: Pruning Empty Payforms
   Given I have the following payform items
      | category  | user_login | hours | description        | date          |
      | Magic     | hg9        | 2     | fighting Voldemort | May 18, 2009  |
      | Quidditch | hp123      | 1.5   | caught the snitch  | June 10, 2009 |
      Then I should see "2009-06-13"
    And I should see "2009-06-06"
    When I follow "Prune all empty payforms"
    Then I should see "Successfully pruned empty payforms."
    And I should see "Harry Potter"
    And I should see "2009-06-13"
    And I should see "Hermione Granger"
    And I should see "2009-05-23"
    And I should not see "2009-06-06"
    And I should not see "2009-05-16"

  Scenario: Payform settings: Disabled Categories vs Miscellaneous
    Given "Harry Potter" has a current payform
    And "Harry Potter" has the following current payform item
      | category  | hours | description   |
      | Quidditch | 2     | played a game |
    When I check "department_config_show_disabled_cats"
    And I press "Submit"
    And I disable the "Work" category
    And I follow "Logout"
    Given I am "Harry Potter"
    And I am on the payforms page
    Then I should see "Quidditch"

    When I follow "Logout"
    Given I am "Albus Dumbledore"
    And I am on the department settings page
    When I uncheck "department_config_show_disabled_cats"
    And I press "Submit"
    And I follow "Logout"
    Given I am "Harry Potter"
    And I am on the payforms page
    Then I should not see "Quidditch"
    And I should see "Miscellaneous"

