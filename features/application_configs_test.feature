@configs
@cw
Feature: Application Configs
  In order to manage application settings
  As a super user
  I want manage the application settings

  Background:
    Given the user "Albus Dumbledore" is a superuser
    And I am "Albus Dumbledore"
    And I am on the Application Settings page
    And I fill in "App email address" with "testing@contact.ben"

@passing
  Scenario: Footer
    When I fill in "Footer" with "Hogwarts University"
    And I press "Submit"
    Then I should see "Successfully updated appconfig."
    When I go to the homepage
    Then I should see "Hogwarts University" in the footer

    When I go to the Application Settings page
    And I fill in "Footer" with "Jedi Academy /n <a href= 'www.jediAcad.edu'> Jedi Rule </a>"
    And I press "Submit"
    Then I should see "Successfully updated appconfig."
    When I go to the homepage
    Then I should see "Jedi Academy" in the footer
    And I should see "Jedi Rule" in the footer

@passing
  Scenario: LDAP Settings
    When I fill in "Ldap host address" with "directory.yale.edu"
    And I fill in "Ldap port" with "389"
    And I fill in "Ldap base" with "ou=People,o=yale.edu"
    And I fill in "Ldap login" with "uid"
    And I fill in "Ldap first name" with "givenname"
    And I fill in "Ldap last name" with "sn"
    And I fill in "Ldap email" with "mail"
    And I press "Submit"
    Then I should see "Successfully updated appconfig."
    And the "ldap_host_address" should be "directory.yale.edu"
    And the "ldap_port" should be "389"
    And the "ldap_base" should be "ou=People,o=yale.edu"
    And the "ldap_login" should be "uid"
    And the "ldap_first_name" should be "givenname"
    And the "ldap_last_name" should be "sn"
    And the "ldap_email" should be "mail"

  Scenario: Email: Site admin email address
    When I fill in "Site Admin Email Address" with "dumbledore@hogwarts.edu"
    And I press "Save"
    Then I should see "Site Admin Email Address successfully saved"

    When I go to the homepage
    Then I should see "Questions? Please email dumbledore@hogwarts.edu"

