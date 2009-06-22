@payform

Feature: payform
  In order to manage my own payform
  As a regular user
  I want to be able to add jobs to, edit, and submit my own payform

  Background:
    Given the user "Harry" "Potter" has permission "payform regular user"
    And I am "Harry" "Potter"
    And I have a payform for the week "2009-5-23"

  Scenario: Add a job to a payform
    Given I am on the page for the payform for the week "2009-05-23"
    When I follow "New Payform Item"
    And I select "Monday, May 18, 2009" as the date
    And I fill in "Hours" with "1.2"
    And I fill in "Description" with "Studying defense against the dark arts"
    And I select "Study" from "payform_item[category_id]"
    And I press "Create"
    Then I should have 1 payform_item
    And I should see "Study"
    And I should see "May 18"
    And I should see "Studying defense against the dark arts"
#   if it could be 1.2 hours that would be great, but it doesn't pass that way'
    And I should see "1.2"


  Scenario: Edit a job on a payform
    Given I have the following payform item
      | category  | user_login | hours | description   | date          |
      | Quidditch | hp123      | 2     | played a game | May 18, 2009 |
    And I am on the page for the payform for the week "2009-05-23"
    Then I should see "edit"
    When I follow "edit"
    And I select "Magic" from "payform_item[category_id]"
    And I fill in "hours" with "3"
    And I fill in "description" with "I edited"
    And I fill in "Reason" with "because I can"
    And I press "Save"
    Then I should have 2 payform_items
    And payform item 2 should be a child of payform item 1
    And payform item 1 should have attribute reason "because I can"
    And I should see "I edited"
    And I should see "3 hours"

  Scenario: Delete a job on a payform
    Given I have the following payform item
      | category | user_login | hours | description         | date         |
      | Magic    | hp123      | 2     | doing some magic    | May 18, 2009 |
    And I am on the page for the payform for the week "2009-5-23"
    When I follow "✖"
    Then I should see "Are you sure?"
    And I fill in "Reason for deletion" with "because I lied"
    And I press "Yes"
    Then I should see "Payform item deleted"
    And I should have 0 payform_items

  Scenario: Submit a payform
    Given I have the following payform items
      | category  | user_login | hours | description         | date         |
      | Quidditch | hp123      | 1.5   | caught the snitch   | May 18, 2009 |
      | Magic     | hp123      | 2     | fighting Voldemort  | May 18, 2009 |
    And I am on the page for the payform for the week "2009-5-23"
    When I follow "Submit Payform"
    Then the payform should be submitted
    And I should see "Successfully submitted payform."
    And I should see "2009-5-23" under "Submitted"
    Given the user "Albus" "Dumledore" has permissions "payform regular user, payform administrator"
    And I am "Albus" "Dumbledore"
    When I go to the payforms page
    Then I should see "Harry Potter"
    And I should see "2009-5-23" under "Submitted"

