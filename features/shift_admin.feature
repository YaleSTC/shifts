Feature: Shift admin manages shifts
  In order to manage shifts
  As a shifts admininistrator
  I want to be able to create, assign, and destroy shifts

Scenario: Create a shift with power sign up
  Given I am logged into CAS as "ad12"
#  Given I am "Adam" "Bray"
  And I am on the homepage
	And I follow "Shifts"
	Then I should see "Power sign up"
	When I follow "Power sign up"
  And I select "2010" from "shift_start_1i"
	And I select "January" from "shift_start_2i"
	And I select "18" from "shift_start_3i"
	And I select "09" from "shift_start_4i"
	And I select "00" from "shift_start_5i"
	And I select "2010" from "shift_end_1i"
	And I select "January" from "shift_end_2i"
	And I select "18" from "shift_end_3i"
	And I select "12" from "shift_end_4i"
	And I select "00" from "shift_end_5i"
	And I select "Harry Potter" from "shift_user_id"
	And I select "Diagon Alley" from "shift_location_id"
	When I press "Submit"
	Then I should see "Successfully created shift."

Scenario: Destroy a shift
  Given I am logged into CAS as "ad12"
  And I am on the homepage
	And I follow "Shifts"
	Then I should see "Power sign up"
	When I follow "Power sign up"
  And I select "2010" from "shift_start_1i"
	And I select "January" from "shift_start_2i"
	And I select "18" from "shift_start_3i"
	And I select "09" from "shift_start_4i"
	And I select "00" from "shift_start_5i"
	And I select "2010" from "shift_end_1i"
	And I select "January" from "shift_end_2i"
	And I select "18" from "shift_end_3i"
	And I select "12" from "shift_end_4i"
	And I select "00" from "shift_end_5i"
	And I select "Harry Potter" from "shift_user_id"
	And I select "Diagon Alley" from "shift_location_id"
	When I press "Submit"
	Then I should see "Successfully created shift."
	When I follow "Shifts"
	And I follow "Destroy"
	Then I should see "Successfully destroyed shift."

Scenario Outline: See more choices when logged in as admin
Given I am logged into CAS as <user>
Given I am on the homepage
Then I should see <item>
Then I should not see <not-item>

Scenarios: Logged in as superuser

|user  |item         |not-item  |
|"ad12"|"Dashboard"  |"studcomp"|
|"ad12"|"Hogwarts"   |"studcomp"|
|"ad12"|"Users"      |"studcomp"|
|"ad12"|"Shifts"     |"studcomp"|
|"ad12"|"Payforms"   |"studcomp"|

Scenarios: Logged in as normal user

|user    |item         |not-item     |
|"em123" |"Dashboard"  |"Departments"|
|"em123" |"Dashboard"  |"Users"      |
|"em123" |"Shifts"     |"Departments"|
|"em123" |"Shifts"     |"Users"      |
|"em123" |"Payforms"   |"Departments"|
|"em123" |"Payforms"   |"Users"      |

