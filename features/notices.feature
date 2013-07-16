@notices
Feature: Notices

  Background:
    Given "Harry Potter, Hermione Granger, Albus Dumbledore" are only in the department "Hogwarts"
    And the user "Harry Potter" has permissions "Outside of Hogwarts view, Outside of Hogwarts signup, Inside of Hogwarts view, Inside of Hogwarts signup"
    And the user "Hermione Granger" has permissions "Outside of Hogwarts view, Outside of Hogwarts signup, Inside of Hogwarts view, Inside of Hogwarts signup"
    And the user "Albus Dumbledore" has permission "Hogwarts dept admin"
    And I am "Harry Potter"
    And I am on the homepage

@passing
  Scenario: A regular user should not be able to create announcements
    When I follow "Notices"
    And I follow "Post a new notice"
    Then I should not see "Type of notice:"
    And I should not see "Start time:"
    And I should not see "End time:"
    And I should not see "Hogwarts (all locations)"

@passing
  Scenario: An admin should be able to create announcements
    Given I am "Albus Dumbledore"
    And I am on the homepage
    When I follow "Notices"
    And I follow "Post a new notice"
    Then I should see "Type of notice:"
    And I should see "Start time:"
    And I should see "End time:"
    And I should see "Hogwarts (all locations)"

  Scenario: Creating a sticky from the dashboard for users
    When I follow "Notices"
    And I follow "Post a new notice"
    And I fill in "notice[content]" with "Hello world!"
    And I fill in "Display for the following users, roles, or departments" with "Albus Dumbledore, hp123"
    And I press "Save"
    Then I should see "Notice was successfully created"
    And I should have 1 notice

    When I go to the homepage
    Then I should see "Notices for you"
    And I should see "Hello world!"
    And I should see "by Harry Potter"
    And I should see "[x]"

    Given I am "Hermione Granger"
    And I am on the homepage
    Then I should not see "Notices for you"
    And I should not see "Hello world!"

    Given I am "Albus Dumbledore"
    And I am on the homepage
    Then I should see "Notices for you"
    And I should see "Hello world!"
    And I should see "by Harry Potter"

  Scenario: Creaing a sticky from the dashboard for locations
    When I follow "Notices"
    And I follow "Post a new notice"
    And I fill in "notice[content]" with "Hello again!"
    And I check "Diagon Alley"
    And I press "Save"
    Then I should see "Notice was successfully created"
    And I should have 1 notice

    When I go to the homepage
    Then I should not see "Notices for you"
    And I should not see "Hello again!"

    When I sign into an unscheduled shift in "Diagon Alley"
    Then I should see "Hello again!"
    When I press "End shift"

    When I sign into an unscheduled shift in "Forbidden Forest"
    Then I should not see "Hello again!"
    When I press "End shift"

    When I sign into an unscheduled shift in "Common Room"
    Then I should not see "Hello again!"
    When I press "End shift"

    Given I am "Hermione Granger"
    When I sign into an unscheduled shift in "Diagon Alley"
    Then I should see "Hello again!"

  Scenario: Creaing a sticky from the dashboard for location groups
    When I follow "Notices"
    And I follow "Post a new notice"
    And I fill in "notice[content]" with "Another sticky!"
    And I check "Inside of Hogwarts"
    And I press "Save"
    Then I should see "Notice was successfully created"
    And I should have 1 notice

    When I go to the homepage
    Then I should not see "Notices for you"
    And I should not see "Another sticky!"

    When I sign into an unscheduled shift in "Common Room"
    Then I should see "Another sticky!"
    When I press "End shift"

    When I sign into an unscheduled shift in "Forbidden Forest"
    Then I should not see "Another sticky!"
    When I press "End shift"

    When I sign into an unscheduled shift in "Diagon Alley"
    Then I should not see "Another sticky!"
    When I press "End shift"

    Given I am "Hermione Granger"
    When I sign into an unscheduled shift in "Potions"
    Then I should see "Another sticky!"

  Scenario: Creating a sticky from the report page without advanced settings
    When I sign into an unscheduled shift in "Potions"
    And I follow "Post a new notice"
    And I fill in "notice[content]" with "I should only see this in the Potions location"
    And I press "Save"
    Then I should see "Notice was successfully created"
    And I should have 1 notice
    And I should see "I should only see this in the Potions location"
    When I press "End shift"

    And I sign into an unscheduled shift in "Common Room"
    Then I should not see "I should only see this in the Potions location"
    When I press "End shift"

    And I sign into an unscheduled shift in "Diagon Alley"
    Then I should not see "I should only see this in the Potions location"
    When I press "End shift"

    Given I am "Hermione Granger"
    When I sign into an unscheduled shift in "Potions"
    Then I should see "I should only see this in the Potions location"

  Scenario: Creating a department-wide announcement from the dashboard
    Given I am "Albus Dumbledore"
    And I am on the homepage
    When I follow "Notices"
    And I follow "Post a new notice"
    And I fill in "notice[content]" with "Everybody should see this!"
    And I check "Hogwarts"
    And I press "Save"
    Then I should see "Notice was successfully created"
    And I should have 1 notice

    When I go to the homepage
    Then I should see "Everybody should see this!"
    And I should see "[x]"
    And I should see "Edit"

    Given I am "Harry Potter"
    And I am on the homepage
    Then I should see "Everybody should see this!"
    And I should not see "[x]"
    And I should not see "Edit"

    Given I am "Hermione Granger"
    And I am on the homepage
    Then I should see "Everybody should see this!"
    And I should not see "[x]"
    And I should not see "Edit"

