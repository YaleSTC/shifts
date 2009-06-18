Feature: Application settings
  In order to manage application settings
  As a super user
  I want manage the application settings

  Background:
    Given I am "Albus Dumbledore"
    And I am on the Application Settings page

  Scenario: Footer
    When I fill in "Footer" with "Hogwarts University"
    And I press "Save"
    And I go to the homepage
    Then I should see "Hogwarts University"

  Scenario: Email: SMTP

  Scenario: Email: Site admin email address

  Scenario: Changing Authentication settings

