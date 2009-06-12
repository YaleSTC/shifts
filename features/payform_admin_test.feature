Feature: payform admin
  In order to manage payforms
  As an admin
  I want to be able to approve, print, and perform other administrative tasks for payforms

  Background:
    Given the user "Albus Dumledore" has permissions "payform regular user, payform administrator"
    And I am "Albus Dumbledore"
    And I have the following payforms:
      | date       | department | user             | submitted | approved |printed|
      | 2009-06-13 | Hogwarts   | Harry Potter     | nil       | nil      | nil   |
      | 2009-06-06 | Hogwarts   | Harry Potter     | true      | nil      | nil   |
      | 2009-05-23 | Hogwarts   | Hermione Granger | true      | true     | nil   |
      | 2009-05-16 | Hogwarts   | Hermione Granger | true      | true     | true  |
    And I am on the payforms page

  Scenario: Creating a Mass Job
    When I follow "Add jobs en masse"
    And I select "2009-06-13" from "Last Day of Pay Week"
    And I select "Quidditch" from "Category"
    And I select "2" from "hours"
    And I select "0" from "minutes"
    And I select "Tuesday, June 09, 2009" from "Date"
    And I fill in "Description" with "great game!"
    And I fill in "Add users in a group: (enter to add)" with "hp123, hg9"
    And I press "Save"
    Then I should see "Job created successfully for the following users: Harry Potter and Hermione Granger"

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

