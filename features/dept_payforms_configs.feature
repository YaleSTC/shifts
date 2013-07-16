@configs
@cw
Feature: Payform settings
  In order to manage payform settings
  As an admin
  I want to be able to configure payform settings

  Background:
    Given I am "Albus Dumbledore"
    And the user "Albus Dumbledore" has permission "Hogwarts dept admin"
    And I am on the department settings page

  Scenario: Payform settings: Min Length for Item description
    When I fill in "department_config_description_min" with "12"
    And I press "Save"
    And I follow "Logout"
    Given I am "Harry Potter"
    And "Harry Potter" has a current payform
    And I have no payform_items
    When I go to the homepage
    And I follow "Payforms"

    And I follow "New Payform Item"
    And I select "03" from "time_input_start_4i"
    And I select "00" from "time_input_start_5i"
    And I select "PM" from "time_input_start_7i"
    And I select "05" from "time_input_end_4i"
    And I select "00" from "time_input_end_5i"
    And I select "PM" from "time_input_end_7i"
    And I select "Study" from "payform_item_category_id"
    And I fill in "Description" with "description"
    And I press "Create"
    Then I should see "Description is too short"
    And I should have 0 payform_items
    When I fill in "Description" with "a longer description"
    And I press "Create"
    Then I should see "Successfully created payform item."
    And I should have 1 payform_item

  Scenario: Payform settings: Min Length for edit and deletion of reason
    Given "Harry Potter" has a current payform
    And "Harry Potter" has the following current payform item
      | category  | hours | description   |
      | Quidditch | 2     | played a game |
    When I fill in "department_config[reason_min]" with "7"
    And I press "Save"
    And I follow "Logout"
    Given I am "Harry Potter"
    And I am on the payforms page
    And I follow "2009-08-08"
    And I follow "edit"
    And I choose "calculate_hours_time_input"
    And I select "03" from "time_input_start_4i"
    And I select "00" from "time_input_start_5i"
    And I select "PM" from "time_input_start_7i"
    And I select "05" from "time_input_end_4i"
    And I select "00" from "time_input_end_5i"
    And I select "PM" from "time_input_end_7i"
    And I fill in "Reason" with "edited"
    And I press "Save"
    Then I should see "Reason seems too short"
    And I should have 1 payform_item
    Given I fill in "Reason" with "a longer reason"
    And I press "Submit"
    Then I should see "Payform item edited"
    And I should have 2 payform_items

    When I follow "✖"
    And I fill in "Reason" with "delete"
    And I press "Delete"
    Then I should see "Reason seems too short"
    And I should have 1 payform_item
    And payform item 1 should have attribute "active" "true"
    When I fill in "Reason" with "a longer reason"
    And I press "Delete"
    Then I should see "Payform item destroyed"
    And I should have 1 payform_item
    And payform item 1 should have attribute "active" "false"

