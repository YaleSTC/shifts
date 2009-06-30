Feature: Authentication Systems
  In order to manage application settings
  As a super user
  I want manage the application settings

  Scenario Outline: Setting the authentication system
    Given I am "Albus Dumbledore"
    And I am on the Application Settings page
    When I choose "<system>"
    And I press "Save"
    Then I should see "Authentication System preference saved."

    When I follow "logout"
    And I go to the homepage
    And I follow "Login"
    Then I should <register>
    And I should <CAS>
    And I should <OpenID>

    Examples:
      | system              | register           | CAS           | OpenID           |
      | Authlogic (generic) | see "Register"     | not see "CAS" | not see "OpenID" |
      | CAS                 | not see "Register" | see "CAS"     | not see "OpenID" |
      | OpenID              | not see "Register" | not see "CAS" | see "OpenID"     |

