Feature: Shift login test

Scenario: Logging in
  Given I just got through CAS with the login "mpl36"
  And I am on the homepage
  Then I should see "mpl36"
  And I should not see "Login"

