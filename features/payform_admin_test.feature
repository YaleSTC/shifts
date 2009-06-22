@payform

Feature: payform admin
  In order to manage payforms
  As an admin
  I want to be able to approve, print, and perform other administrative tasks for payforms

  Background:
    Given the user "Albus" "Dumledore" has permissions "payform regular user, payform administrator"
    And I am "Albus" "Dumbledore"
    And I have the following payforms:
      | date       | department | user_first | user_last      | submitted | approved |printed|
      | 2009-06-13 | Hogwarts   | Harry      | Potter         | nil       | nil      | nil   |
      | 2009-06-06 | Hogwarts   | Harry      | Potter         | true      | nil      | nil   |
      | 2009-05-23 | Hogwarts   | Hermione   | Granger        | true      | true     | nil   |
      | 2009-05-16 | Hogwarts   | Hermione   | Granger        | true      | true     | true  |
    And I am on the payforms page

  Scenario: Creating a Mass Job
    Given I have no payform_item_sets
    When I follow "Mass Add Jobs"
    And I select "2009-06-13" from "Last Day of Pay Week"
    And I select "Quidditch" from "Category"
    And I select "2" from "hours"
    And I select "0" from "minutes"
    And I select "Tuesday, June 09, 2009" from "Date"
    And I fill in "Description" with "great game!"
    And I fill in "Search users" with "hp123, hg9"
    And I press "Save"
    Then I should have 1 punch_clock
    And I should see "Job created successfully for the following users: Harry Potter and Hermione Granger"
    When I go to the list of mass jobs
    Then I should see "Quidditch"
    And I should see "2009-6-9"
    And I should see "2.0 hours"
    And the user "hp123" should have 1 payform_item
    And the user "hg9" should have 1 payform_item

  Scenario: Creating a punch clock
    Given I have no punch_clocks
    When I follow "Mass Punch Clocks"
    And I follow "Add Mass Clock"
    And I select "Quidditch" from "Category"
    And I fill in "Description" with "Starting the game"
    And I fill in "Search user" with "hp123, hg9"
    And I press "Clock Users In"
    Then I should see "Mass Punch Clock created for the following users: Harry Potter and Hermione Granger"
    When I go to Mass Punch Clocks page
    Then I should see "1 active clock"
    And I should see "Harry Potter"
    And I should see "Hermione Granger"

  Scenario: Viewing payforms
    Then I should see "Harry Potter"
    And I should see "2009-06-13" under "Unsubmitted"
    And I should see "2009-06-06" under "Unapproved"
    And I should see "Hermione Granger"
    And I should see "2009-05-23" under "Unprinted"
    And I should not see "2009-05-16"

  Scenario: Approving payforms
    When I follow "2009-06-06"
    And I follow "Approve"
    Then I should see "Payform approved."
    And I should see "2009-06-06" under "Unprinted"

  Scenario: Printing payforms
    When I follow "2009-05-23"
    And I follow "Print"
    Then I should see "Payform printing"
    And I should not see "2009-05-23"

