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

  Scenario: LDAP Settings
    When I fill in "Ldap address" with "2222"
    And I press "Submit"
    Then I should see "Successfully updated appconfig."
    And the ldap address should be "2222"

  Scenario: Email: Site admin email address
    When I fill in "Site Admin Email Address" with "dumbledore@hogwarts.edu"
    And I press "Save"
    Then I should see "Site Admin Email Address successfully saved"

    When I go to the homepage
    Then I should see "Questions? Please email dumbledore@hogwarts.edu"

