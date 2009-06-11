Feature: payform admin
  In order to manage payforms
  As an admin
  I want to be able to approve, print, and perform other administrative tasks for payforms

    Background:
        Given I am a payform administrator
        And I have a category "Saving the World"
        And I have a user named "Frodo", department "Middle Earth", login "fb3"
        And I have a user named "Sam", department "Middle Earth", login "sg23"
        And I have the following payforms:
            |date      | department   | user | submitted | approved |printed|
            |2009-06-13| Middle Earth | Frodo| nil       | nil      | nil   |
            |2009-06-06| Middle Earth | Frodo| true      | nil      | nil   |
            |2009-05-23| Middle Earth | Sam  | true      | true     | nil   |
            |2009-05-16| Middle Earth | Sam  | true      | true     | true  |


    Scenario: Creating a Payform Item Set
        Given I am on the Add Jobs en Masse page
        When I select "2009-06-13" from "Last Day of Pay Week"
        And I select "Saving the World" from "Category"
        And I select "2" from "hours"
        And I select "0" from "minutes"
        And I select "Tuesday, June 09, 2009" from "Date"
        And I fill in "Description" with "defeated the Dark Lord"
        And I fill in "Add users in a group: (enter to add)" with "fb3, sg23"
        And I follow "Save"
        Then I should see "Job created successfully for the following users: Frodo and Sam"

    Scenario: Viewing payforms
        Given I am on the Payform Admin page
        Then I should see "Frodo"
        And I should see "2009-06-13" under "Unsubmitted"
        And I should see "2009-06-06" under "Unapproved"
        And I should see "Sam"
        And I should see "2009-05-23" under "Unprinted"
        And I should not see "2009-05-16"

    Scenario: Approving payforms
        Given I am on the Payform Admin page
        When I follow "2009-06-06"
        And I follow "Approve"
        Then I should see "Payform approved."
        And I should see "2009-06-06" under "Unprinted"

    Scenario: Printing payforms
        Given I am on the Payform Admin page
        When I follow "2009-05-23"
        And I follow "Print"
        Then I should see "Payform printing"

