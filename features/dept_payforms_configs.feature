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

  Scenario: Payform settings: Reminder email text and times
    Given I have the following payforms:
      | date       | department | user_first | user_last      | submitted | approved |printed|
      | 2009-06-13 | Hogwarts   | Harry      | Potter         | nil       | nil      | nil   |
      | 2009-06-06 | Hogwarts   | Harry      | Potter         | true      | nil      | nil   |
      | 2009-05-09 | Hogwarts   | Harry      | Potter         | true      | true     | nil   |
      | 2009-05-23 | Hogwarts   | Hermione   | Granger        | true      | true     | nil   |
      | 2009-05-16 | Hogwarts   | Hermione   | Granger        | true      | true     | true  |


  Scenario: Payform settings: Min Length for Item description
    When I fill in "department_config_description_min" with "7"
    And I press "Submit"
    And I follow "Logout"
    Given I am "Harry Potter"
    And "Harry Potter" has a current payform
    And I have no payform_items
    When I go to the homepage
    And I follow "Payforms"

    And I follow "New Payform Item"
    And I select "2" from "other_hours"
    And I select "Study" from "Category"
    And I fill in "Description" with "hello"
    And I press "Create"
    Then I should see "Description seems too short"
    And I should have 0 payform_items
    When I fill in "Description" with "a longer description"
    And I press "Create"
    Then I should see "Payform item successfully created"
    And I should have 1 payform_item


  Scenario: Payform settings: Min Length for edit and deletion of reason
    Given "Harry Potter" has a current payform
    And "Harry Potter" has the following current payform item
      | category  | hours | description   |
      | Quidditch | 2     | played a game |
    When I fill in "department_config[reason_min]" with "7"
    And I press "Submit"
    And I follow "Logout"
    Given I am "Harry Potter"
    And I am on the payforms page
    And I follow "edit"
    And I fill in "Hours" with "3"
    And I fill in "Reason" with "edited"
    And I press "Submit"
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
@t
  Scenario: Payform settings: Disabled Categories vs Miscellaneous
#    Given "Harry Potter" has a current payform
    Given "Harry Potter" has the following current payform item
      | category  | hours | description   |
      | Quidditch | 2     | played a game |
    Then test test test 1
    When I check "department_config_show_disabled_cats"
    Then test test test 1
    And I press "Submit"
    Then test test test 1
    And I disable the "Quidditch" category
    Then test test test 1
    And I follow "Logout"
    Then test test test 1
    Given I am "Harry Potter"
    Then test test test 1
    And I am on the payform for this week
    Then test test test 1
    Then I should see "Quidditch"

    When I follow "Logout"
    Given I am "Albus Dumbledore"
    And I am on the department settings page
    When I uncheck "department_config_show_disabled_cats"
    And I press "Submit"
    And I follow "Logout"
    Given I am "Harry Potter"
    And I am on the payforms page
    Then I should not see "Quidditch"
    And I should see "Miscellaneous"

