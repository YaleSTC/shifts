@payform
@cw

Feature: payform emails
  In order to manage payforms
  As an admin
  I want to be able to have emails automatically go out at certain times

  Background:
    Given the user "Albus Dumbledore" has permissions "Hogwarts payforms admin"
    And I am "Albus Dumbledore"
    And I have the following payforms:
      | date       | department | user_first | user_last | submitted | approved |printed|
      | 2009-06-13 | Hogwarts   | Harry      | Potter    | nil       | nil      | nil   |
#      | 2.weeks.ago | Hogwarts  | Harry      | Potter    | nil       | nil      | nil   |
    And I am on the payforms page

  Scenario: Email when payform item is changed by admin
    Given I have the following payform items
      | category  | user_login | hours | description        | date         |
      | Quidditch | hp123      | 1.5   | caught the snitch  | June 8, 2009 |
    When I follow "2009-06-13"
    And I follow "edit"
    And I select "2009-06-10" from "Date"
    And I fill in "Hours" with "2"
    And I select "Study" from "payform_item[category_id]"
    And I fill in "Description" with "learning about cornish pixies"
    And I fill in "Reason" with "He made a mistake."
    And I press "Save"
    Then I should have 2 payform_items
    And payform item 1 should be a child of payform item 2
    And payform_item 2 should have attribute "reason" "He made a mistake."
    And I should see "Successfully edited payform item."
    And I should see "2.0"

    And "hp123@hogwarts.edu" should receive 1 email
    When "hp123@hogwarts.edu" opens the email with text "Hi Harry Potter, Albus Dumbledore has modified your payform item for June 8, 2009. Best, STC P.S. Penguins! We thought you should know"

  Scenario: Email when payform item is deleted by admin
    Given I have the following payform items
      | category  | user_login | hours | description        | date         |
      | Quidditch | hp123      | 1.5   | caught the snitch  | June 8, 2009 |
    When I follow "2009-06-13"
    And I follow "✖"
#    And I fill in "Reason" with "He was sick."
    Then I should see "Payform item deleted"
    And I should have 1 payform_item
    And that payform_item should be inactive
    And "hp123@hogwarts.edu" should receive 1 email
    When "hp123@hogwarts.edu" opens the email with text "Hi Harry Potter, Albus Dumbledore has deleted your payform item for June 8, 2009. Best, STC P.S. Penguins! We thought you should know"

  Scenario: Auto-Email when payforms have not been submitted for 2 weeks
    When I am on the department settings page
    And I fill in "warning_weeks" with "2"
    And I fill in "reminder_message" with "Dear #name, /n You have an unsubmitted payform more than 2 weeks old. Please submit it as soon as possible. /n Thanks, A. Dumbledore"
    And I press "Save"
    Then I should see "Successfully updated department config."

    Given "Harry Potter" has an unsubmitted payform from "3" weeks ago with 1 payform_item
    Then "hp123@hogwarts.edu" should receive 1 email
    When "hp123@hogwarts.edu" opens the email with text "Dear Harry Potter, /n You have an unsubmitted payform more than 2 weeks old. Please submit it as soon as possible. /n Thanks, A. Dumbledore"

