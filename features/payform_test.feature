@payform
Feature: payform
  In order to manage my own payform
  As a regular user
  I want to be able to add jobs to, edit, and submit my own payform

  Background:
    Given I am "Harry Potter"
    And I have a payform for the week "2009-5-23"
@passing
  Scenario: Add a job to a payform
    Given I am on the page for the payform for the week "2009-05-23"
    When I follow "New Payform Item"
    And I select "2009-05-18" from "Date"
    And I choose "calculate_hours_time_input"
    And I select "03" from "time_input_start_4i"
    And I select "00" from "time_input_start_5i"
    And I select "PM" from "time_input_start_7i"
    And I select "04" from "time_input_end_4i"
    And I select "12" from "time_input_end_5i"
    And I select "PM" from "time_input_end_7i"
    And I fill in "Description" with "Studying defense against the dark arts"
    And I select "Study" from "payform_item[category_id]"
    And I press "Create"
    Then I should have 1 payform_item
    And I should see "Study"
    And I should see "May 18"
    And I should see "Studying defense against the dark arts"
    And I should see "1.2"
@passing
  Scenario: Edit a job on a payform
    Given I have the following payform item
      | category  | user_login | hours | description   | date          |
      | Quidditch | hp123      | 2     | played a game | May 18, 2009 |
    And I am on the page for the payform for the week "2009-05-23"
    Then I should see "edit"
    When I follow "edit"
    And I select "Magic" from "payform_item[category_id]"
    And I choose "calculate_hours_time_input"
    And I select "03" from "time_input_start_4i"
    And I select "00" from "time_input_start_5i"
    And I select "PM" from "time_input_start_7i"
    And I select "06" from "time_input_end_4i"
    And I select "00" from "time_input_end_5i"
    And I select "PM" from "time_input_end_7i"
    And I fill in "description" with "I edited this payform item"
    And I fill in "Reason" with "because I can"
    And I press "Save"
    Then I should have 2 payform_items
    Then payform item 1 should be a child of payform item 2
    And payform_item 1 should have attribute "reason" "because I can"
    And I should see "I edited"
    And I should see "3.0"

@passing
  Scenario: Delete a job on a payform
    Given I have the following payform item
      | category | user_login | hours | description         | date         |
      | Magic    | hp123      | 2     | doing some magic    | May 18, 2009 |
    And I am on the payforms page
    When I follow "2009-05-23"
    And I follow "✖"
    Then I should see "Destroy Payform Item"
    And I fill in "Reason" with "because I lied"
    And I press "Delete"
#    Then I should see "Payform item deleted"
    And I should have 1 payform_item
    And that payform_item should be inactive

@passing
  Scenario: Submit a payform
    Given I have the following payform items
      | category  | user_login | hours | description         | date         |
      | Quidditch | hp123      | 1.5   | caught the snitch   | May 18, 2009 |
      | Magic     | hp123      | 2     | fighting Voldemort  | May 18, 2009 |
    And I am on the page for the payform for the week "2009-5-23"
    When I follow "Submit Payform"
    Then I should see "Successfully submitted payform."
    And the payform should be submitted
    When I follow "Logout"
    Given the user "Albus Dumbledore" has permission "Hogwarts payforms admin"
    And I am "Albus Dumbledore"
    When I go to the payforms page
    Then I should see "Harry Potter"
    And I should see "2009-05-23" under "Submitted" in column 3

