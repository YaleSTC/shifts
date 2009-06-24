Feature: Authentication Systems
  In order to manage application settings
  As a super user
  I want manage the application settings

  Scenario: Setting the authentication system
    Given I am "Albus Dumbledore"
    And I am on the Application Settings page
    When I choose "<system>"
    And I press "Save"
    Then I should see "Authentication System preference saved."

    When I logout
    And I go to the homepage
    And I follow "Login"
    Then I should <register> see "Register"
    And I should <CAS> see "CAS"
    And I should <OpenID> see "OpenID"

    Examples:
      | system              | register | CAS | OpenID |
      | Authlogic (generic) |          | not | not    |
      | CAS                 | not      |     | not    |
      | OpenID              | not      | not |        |

