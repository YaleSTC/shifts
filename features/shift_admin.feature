Feature: Shift admin manages shifts
  In order to manage shifts
  As a shifts admininistrator
  I want to be able to create, assign, and destroy shifts

Scenario: Create a shift with power sign up
  Given I just got through CAS with the login "catest"
	And I am on the homepage
	When I follow "STC"
	And I follow "Shifts"
	And I follow "Power sign up"
	  And I select "2010" from "shift_start_1i"
	  And I select "January" from "shift_start_2i"
	  And I select "18" from "shift_start_3i"
	  And I select "09" from "shift_start_4i"
	  And I select "00" from "shift_start_5i"
	  And I select "2010" from "shift_end_1i"
	  And I select "January" from "shift_end_2i"
	  And I select "18" from "shift_end_3i"
	  And I select "17" from "shift_end_4i"
	  And I select "00" from "shift_end_5i"
	  And I select "StudComp" from "shift_user_id"
	  And I select "TTO" from "shift_location_id"
	When I press "Submit"
	Then I should see "Successfully created shift."

