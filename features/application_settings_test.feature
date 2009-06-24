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

    When I go to the Applications Settings page
    And I fill in "Footer" with "Jedi Academy /n <a href= 'www.jediAcad.edu'> Jedi Rule </a>"
    And I press "Save"
    And I go to the homepage
    Then I should see "Jedi Academy"
    And I should see "Jedi Rule"

  Scenario: Email: SMTP
    When I fill in "host name" with ""
    And I fill in "port #" with ""
    And I fill in "search base" with ""
    And I fill in "first_name from LDAP" with "given_name"
    And I fill in "last_name from LDAP" with "sn"

  Scenario: Email: Site admin email address
    When I fill in "Site Admin Email Address" with "dumbledore@hogwarts.edu"
    And I press "Save"
    Then I should see "Site Admin Email Address successfully saved"

    When I go to the homepage
    Then I should see "Questions? Please email dumbledore@hogwarts.edu"

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

