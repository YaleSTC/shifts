@payform

Feature: payform admin
  In order to manage payforms
  As an admin
  I want to be able to approve, print, and perform other administrative tasks for payforms

  Background:
    Given I am "Albus Dumbledore"
    Given the user "Albus Dumbledore" has permissions "payform administrator"
    And I have the following payforms:
      | date       | department | user_first | user_last      | submitted | approved |printed|
      | 2009-06-13 | Hogwarts   | Harry      | Potter         | nil       | nil      | nil   |
      | 2009-06-06 | Hogwarts   | Harry      | Potter         | true      | nil      | nil   |
      | 2009-05-23 | Hogwarts   | Hermione   | Granger        | true      | true     | nil   |
      | 2009-05-16 | Hogwarts   | Hermione   | Granger        | true      | true     | true  |
    And I am on the payforms page

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
    And I check "Harry Potter"
    And I check "Hermione Granger"
    And I press "Save"
    Then I should have 1 payform_item_sets
    And I should see "Successfully created payform item set."
    When I go to the list of mass jobs
    Then I should see "Quidditch"
    And I should see "2009-06-09"
    And I should see "Hours"
    And I should see "2.0"
    And "Harry Potter" should have 1 payform_item
    And "Hermione Granger" should have 1 payform_item

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

  Scenario: Approving payforms
    When I follow "2009-06-06"
    And I follow "Approve Payform"
    Then I should see "Successfully approved payform."
    And I should not see "not"
    When I am on the payforms page
    Then I should see "2009-06-06" under "Approved" in column 4

  Scenario: Printing payforms
    When I follow "2009-05-23"
    And I follow "Print"
    Then I should see "Payform printing"
    And I should not see "2009-05-23"

  Scenario: Pruning Empty Payforms
   Given I have the following payform items
      | category  | user_login | hours | description        | date          |
      | Magic     | hg9        | 2     | fighting Voldemort | May 18, 2009  |
      | Quidditch | hp123      | 1.5   | caught the snitch  | June 10, 2009 |
    When I follow "Prune all empty payforms"
    Then I should see "Successfully pruned empty payforms."
    And I should see "2009-06-13"
    And I should see "2009-05-23"
    And I should not see "2009-06-06"
    And I should not see "2009-05-16"

