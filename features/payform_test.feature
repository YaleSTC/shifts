Feature: payform
  In order to manage my own payform
  As a regular user
  I want to be able to add jobs to, edit, and submit my own payform

  Background:
    Given I am user "wy59" in department "STC"
    Given I have the following categories: "Work, Play, Study"
    Given I have a payform for the week "2009-5-23"

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

