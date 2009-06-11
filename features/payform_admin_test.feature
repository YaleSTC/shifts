Feature: payform admin
  In order to manage payforms
  As an admin
  I want to be able to approve, print, and perform other administrative tasks for payforms

    Background:
        Given I am a payform administrator
        And I have a category "Saving the World"
        And I have a user named "Frodo", department "Middle Earth", login "fb3"
        And I have a user named "Sam", department "Middle Earth", login "sg23"

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
        Given I have a submitted payform:
            |date      | department   | user | submitted | approved |printed|
            |2009-06-06| Middle Earth | Frodo| true      | nil      | nil   |
            |2009-06-13| Middle Earth | Frodo| true      | nil      | nil   |
            |2009-06-06| Middle Earth | Sam  | true      | true     | nil   |
            |2009-06-13| Middle Earth | Sam  | true      | true     | true  |
        And I am on the Payform Admin page
        Then I should see "Frodo"
        And I should see "2009-06-09" under "Unapproved"
        And I should see "Sam"
        And I should see "2009-06-06" under "

