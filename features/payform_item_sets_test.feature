Feature: Payform Item Sets
    In order to add a payform item to multiple users
    As a payform administrator
    I want to create, edit and delete a payform item set

    Background:
        Given I am a payform administrator
        And I have a category "Saving the World"
        And I have a user named "Frodo", login "fb3"
        And I have a user named "Sam", login "sg23"

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

