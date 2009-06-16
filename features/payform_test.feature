@payform

Feature: payform
  In order to manage my own payform
  As a regular user
  I want to be able to add jobs to, edit, and submit my own payform

  Background:
    Given the user "Harry Potter" has permission "payform regular user"
    And I am "Harry Potter"
    And I have a payform for the week "2009-5-23"

  Scenario: Add a job to a payform
    Given I am on the page for the payform for the week "2009-5-23"
    When I follow "New Payform Item"
    And I select "Monday, May 18, 2009" from "Date:"
    And I select "Study" from "Category:"
    And I choose "Input hours:"
    And I select "1" from "Hours:"
    And I select "5" from "Minutes:"
    And I fill in "Description:" with "Studying defense against the dark arts"
    And I press "Add job"
    Then I should have 1 payform_item
    And I should see "Study"
    And I should see "2009-5-18"
    And I should see "Studying defense against the dark arts"
    And I should see "1.08 hours"

  Scenario: Edit a job on a payform
    Given I have the following payform item
      | category  | user_login | hours | description   |
      | Quidditch | hp123      | 2     | played a game |
    And I am on the page for the payform for the week "2009-5-23"
    When I follow "edit"
    And I select "Magic" from "Category"
    And I select "3" from "hours"
    And I fill in "description" with "I edited"
    And I fill in "reason" with "because I can"
    And I press "Save"
    Then I should have 2 payform_items
    And payform item 2 should be a child of payform item 1
    And payform item 1 should have attribute reason "because I can"
    And I should see "I edited"
    And I should see "3 hours"

  Scenario: Delete a job on a payform
    Given I have the following payform item
      | category | user_login | hours | description         |
      | Magic    | hp123      | 2     | doing some magic    |
    And I am on the page for the payform for the week "2009-5-23"
    When I follow "delete"
    And I fill in "Reason for deletion" with "because I lied"
    And I press "Yes, please delete this"
    Then I should see "Payform item deleted"
    And I should have 0 payform_items

  Scenario: Submit a payform
    Given I have the following payform items
      | category  | user_login | hours | description         |
      | Quidditch | hp123      | 1.5   | caught the snitch   |
      | Magic     | hp123      | 2     | fighting Voldemort  |
    And I am on the page for the payform for the week "2009-5-23"
    When I press "Submit Payform"
    Then the payform should be submitted
    And I should see "Payform submitted"
    And I should see "2009-5-23" under "Submitted"
    Given the user "Albus Dumledore" has permissions "payform regular user, payform administrator"
    And I am "Albus Dumbledore"
    When I go to the payforms page
    Then I should see "Harry Potter"
    And I should see "2009-5-23" under "Submitted"

