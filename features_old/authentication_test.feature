@auth
@cw

Feature: Authentication Systems
  In order to manage users with different auth_types
  As an application admin
  I want manage the authentication settings

@passing
  Scenario: Using Authlogic to login if CAS is supposed to be your authtype

    When I am on the login page
    And I fill in "Login" with "hp123"
    And I fill in "Password" with "secret"
    And I press "Submit"
    Then I should see "You're not supposed to be using built in authentication. Please click the relevant link below to log in using CAS."
    And I should see "Can't login? Maybe you want to login with CAS?"

    When I follow "reset your password?"
    And I fill in "email" with "hp123@hogwarts.edu"
    And I press "Reset my password"
    Then I should see "No user using built-in authentication was found with that email address"
    And "hp123@hogwarts.edu" should not receive an email
@passing
  Scenario: Using Authlogic to login
    When I am on the login page
    And I fill in "Login" with "filch"
    And I fill in "Password" with "secret"
    And I press "Submit"
    Then I should see "Successfully logged in."
    And I should see "Welcome, Argus Filch"

  Scenario: Reseting Password
    When I am on the login page
    And I follow "reset your password?"
    And I fill in "email" with "argus.filch@squib.com"
    And I press "Reset my password"
    Then I should see "Login"
    And I should see "Can't login? Maybe you want to login with CAS?"

    And "argus.filch@squib.com" should receive 1 email
    When "argus.filch@squib.com" opens the email with text "A request to reset your password has been made. If you did not make this request, simply ignore this email. If you did make this request just click the link below:"
    When I click the first link in the email
    Then I should see "Change My Password"
    Then the "Login" field should contain "filch"
    When I fill in "Password" with "secret2"
    And I fill in "Password Confirmation" with "secret2"
    And I press "Update my password and bring me to the login page"

    Then I should see "Please login."
    When I fill in "Login" with "filch"
    And I fill in "Password" with "secret"
    And I press "Submit"
    Then I should see "Password is not valid"
    When I fill in "Password" with "secret2"
    And I press "Submit"
    Then I should see "Successfully logged in."

@passing
  Scenario: Login Works until the password is actually reset
    When I am on the login page
    And I follow "reset your password?"
    And I fill in "email" with "argus.filch@squib.com"
    And I press "Reset my password"
    Then I should see "Login"
    And I should see "Can't login? Maybe you want to login with CAS?"

    And I fill in "Login" with "filch"
    And I fill in "Password" with "secret"
    And I press "Submit"
    Then I should see "Successfully logged in."
    And I should see "Welcome, Argus Filch"
@passing
  Scenario: Creating a user with AuthLogic
    Given the user "Albus Dumbledore" has permissions "Hogwarts dept admin"
    And I am "Albus Dumbledore"
    And I am on the list of users
    When I follow "Add A New User"
    And I fill in "Login" with "Peeve"
    And I fill in "First Name" with "Peeves"
    And I fill in "Last Name" with "the Poltergeist"
    And I fill in "Email" with "peeves@trouble.com"
    And I select "built-in" from "user_auth_type"
    And I press "Create"
    Then I should see "Successfully created user and emailed instructions for setting password."
    And "peeves@trouble.com" should receive 1 email
    When I follow "Logout"
    And "peeves@trouble.com" opens the email with text "Your profile has been created in the application. If you did not make this request, simply ignore this email. If you did make this request just click the link below:"
    And I click the first link in the email
    Then I should see "Change My Password"
    When I fill in "Password" with "secret"
    And I fill in "Password Confirmation" with "secret"
    And I press "Update my password and bring me to the login page"

    Then I should see "Please login."
    When I fill in "Login" with "Peeve"
    And I fill in "Password" with "secret"
    And I press "Submit"
    Then I should see "Successfully logged in."
    And I should see "Welcome, Peeves the Poltergeist"
@passing
  Scenario: Creating a user with CAS
    Given the user "Albus Dumbledore" has permissions "Hogwarts dept admin"
    And I am "Albus Dumbledore"
    And I am on the list of users
    When I follow "Add A New User"
    And I fill in "Login" with "ll66"
    And I fill in "First Name" with "Luna"
    And I fill in "Last Name" with "Lovegood"
    And I fill in "Email" with "ll66@hogwarts.edu"
    And I select "CAS" from "user_auth_type"
    And I press "Create"
    Then I should see "Successfully created user"
    And "ll66@hogwarts.edu" should not receive an email
    When I follow "Logout"
    Given I am "Luna Lovegood"
    And I am on the homepage
    Then I should see "Welcome, Luna Lovegood"
@wip2
  Scenario: Admin resets user's' password
    Given the user "Albus Dumbledore" has permissions "Hogwarts dept admin"
    And I am "Albus Dumbledore"
    And I go to the page for the user "filch"
    And I check "reset_password"
    And I press "Update"
    Then I should see "Successfully updated user."
    And "argus.filch@squib.com" should receive 1 email
    When I follow "Logout"

    And I go to the login page
    And I fill in "Login" with "filch"
    And I fill in "Password" with "secret"
    And I press "Submit"
    Then I should see "Password is not valid"
    And I should see "Login"
    And I should not see "Welcome, Argus Filch"

