Feature: Authentication Systems
  In order to manage users with different auth_types
  As a application admin
  I want manage the authentication settings

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
    Then I should see "No user using authlogic was found with that email address"

  Scenario: Using Authlogic to login
    When I am on the login page
    And I fill in "Login" with "filch"
    And I fill in "Password" with "secret"
    And I press "Submit"
    Then I should see "Successfully logged in."
    And I should see "Welcome Argus Filch"

  Scenario: Reseting password
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
    And I should see "Welcome Argus Filch"

  Scenario Outline: Creating a user with AuthLogic or CAS
    Given the user "Albus Dumbledore" has permissions "Hogwarts dept admin"
    And I am "Albus Dumbledore"
    And I am on the list of users
    When I follow "Add a New User"
    And I fill in "Login" with "<Login>"
    And I fill in "First Name" with "<First Name>"
    And I fill in "Last Name" with "<Last Name>"
    And I fill in "Email" with "<Email>"
    And I select "<auth_type>" from "user_auth_type"
    And I press "Create"
    Then I should see "<message>"

  Examples:
    | Login | First Name | Last Name      | Email              | auth_type | message |
    | Peeve | Peeves     | the Poltergeist| peeves@trouble.com | authlogic |Successfully created user and emailed instructions for setting password. |
    | ll66  | Luna       | Lovegood       | ll66@hogwarts.edu  | CAS       | Successfully created user.|

  Scenario: Admin resets user's' password
    Given the user "Albus Dumbledore" has permissions "Hogwarts dept admin"
    And I am "Albus Dumbledore"
    And I go to the page for the user "filch"
    And I check "reset_password"
    And I press "Update"
    Then I should see "Successfully updated user."

    When I follow "Logout"
    And I go to the login page
    And I fill in "Login" with "filch"
    And I fill in "Password" with "secret"
    And I press "Submit"
    Then I should see "Password is not valid"
    And I should see "Login"
    And I should not see "Welcome Argus Filch"

