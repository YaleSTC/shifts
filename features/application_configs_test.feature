@configs

Feature: Application Configs
  In order to manage application settings
  As a super user
  I want manage the application settings

  Background:
#    Given the user "Albus Dumbledore" is a superuser
    Given I am "Albus Dumbledore"
    And I am on the Application Settings page

  Scenario: Footer
    When I fill in "Footer" with "Hogwarts University"
    And I press "Submit"
    Then I should see "Successfully updated appconfig."
    When I go to the homepage
    Then I should see "Hogwarts University"

    When I go to the Application Settings page
    And I fill in "Footer" with "Jedi Academy /n <a href= 'www.jediAcad.edu'> Jedi Rule </a>"
    And I press "Submit"
    Then I should see "Successfully updated appconfig."
    When I go to the homepage
    Then I should see "Jedi Academy"
    And I should see "Jedi Rule"

  Scenario: User editable logins
    When I check "app_config_user_editable_logins"
    And I press "Submit"
    Then I should see "Successfully updated appconfig."
    When I go to the user settings page
    Then I should not see "Edit login"
    When I follow "Logout"
    And I am "Argus Filch"
    And I go to the user settings page
    And I fill in "Login" with "Awesome"
    And I press "Submit"
    Then I should see "Successfully updated user config"
    And I should see "Awesome"

  Scenario: LDAP Settings
    When I fill in "Ldap address" with "2222"
    And I press "Submit"
    Then I should see "Successfully updated appconfig."

  Scenario: Email: Site admin email address
    When I fill in "Site Admin Email Address" with "dumbledore@hogwarts.edu"
    And I press "Save"
    Then I should see "Site Admin Email Address successfully saved"

    When I go to the homepage
    Then I should see "Questions? Please email dumbledore@hogwarts.edu"

  Scenario Outline: Setting the authentication system
    Given I am "Albus Dumbledore"
    And I am on the Application Settings page
    When I check "<system>"
    And I press "Submit"
    Then I should see "Successfully updated appconfig."

    When I follow "Logout"
    Then I should be redirected
    When I go to the homepage
    Then I should <action>

    Examples:
      | system                               | action         |
      | Central Authentication Service (CAS) | be redirected  |
      | Internal Authentication              | see "Register" |

