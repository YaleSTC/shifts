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

  Scenario: LDAP Settings
    When I fill in "host name" with ""
    And I fill in "port #" with ""
    And I fill in "search base" with ""
    And I fill in "first_name from LDAP" with "given_name"
    And I fill in "last_name from LDAP" with "sn"
    Then I should see ???

  Scenario: Email: Site admin email address
    When I fill in "Site Admin Email Address" with "dumbledore@hogwarts.edu"
    And I press "Save"
    Then I should see "Site Admin Email Address successfully saved"

    When I go to the homepage
    Then I should see "Questions? Please email dumbledore@hogwarts.edu"

  Scenario: Authentication settings: authlogic
    When I choose "Use built in authentication"
    And I press "Save"
    And I log out
    And I go to the homepage
    # Not sure if the following step would work since webrat follows internal redirects
    Then I should be redirected to the login page
    When I fill in "login" with "hp123"
    And I fill in "password" with "password"
    And I press "Log in"
    Then I should be redirected to the homepage
    And I should see "Successfully logged in as Harry Potter"

  Scenario: Authentication settings: CAS
    When I choose "CAS"
    And I press "Save"
    And I log out
    And I go to the homepage
    Then I should be redirected

