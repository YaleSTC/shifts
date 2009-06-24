Feature: Authentication Systems
  In order to manage application settings
  As a super user
  I want manage the application settings

  Scenario: Setting Authlogic
    Given I am "Albus Dumbledore"
    And I am on the Application Settings page
    When I choose "Authlogic (generic) Identification system"
    And I press "Save"
    Then I should see "Authentication System preference saved."

    When I logout
    And I go to the homepage
    And I follow "Login"
    Then I should see "Register"
    And I should not see "CAS"
    And I should not see "OpenID"

  Scenario: Setting CAS
    Given I am "Albus Dumbledore"
    And I am on the Application Settings page
    When I choose "CAS"
    And I press "Save"
    Then I should see "Authentication System preference saved."

    When I logout
    And I go to the homepage
    And I follow "Login"
    Then I should see "CAS"
    And I should not see "register"
    And I should not see "OpenID"

