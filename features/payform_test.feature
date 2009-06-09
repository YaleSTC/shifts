Feature: payform
  In order to manage my own payform
  As a regular user
  I want to be able to add jobs to, edit, and submit my own payform

  Background:
    Given I have a department named "STC"
    And I have a user named "Wei Yan" in the department "STC" with login "wy59"
    And I am user "wy59"
    And I have the following categories: "Work, Play, Study"
    And I have a payform for the week "2009-5-23"

  Scenario: Add a job to a payform
    Given I am on the page for the payform for the week "2009-5-23"
    When I follow "Add Job"
    And I select "Monday, May 18, 2009" from "Date:"
    And I select "Play" from "Category:"
    And I choose "Input hours:"
    And I select "1" from "Hours:"
    And I select "5" from "Minutes:"
    And I fill in "Description:" with "Fiddling around with payform"
    And I press "Add job"
    Then I should have 1 payform_item
    And I should see "Play"
    And I should see "2009-5-18"
    And I should see "Fiddling around with payform"
    And I should see "1.08 hours"

  Scenario: Edit a job on a payform
    Given I have the following payform items
      | category | user_login | hours | description |
      | Work     | wy59       | 2     | my job      |
    And I am on the page for the payform for the week "2009-5-23"
    When I follow "edit"
    And I select "Study" from "Category"
    And I select "3" from "hours"
    And I fill in "description" with "I edited"
    And I fill in "reason" with "because I can"
    And I press "Save"
    Then I should have 2 payform items
    And payform item 2 should be a child of payform item 1
    And payform item 1 should have attribute reason "because I can"
    And I should see "I edited"
    And I should see "3 hours"

