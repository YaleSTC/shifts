Feature: Shift admin manages shifts
  In order to manage shifts
  As a shifts admininistrator
  I want to be able to create, assign, and destroy shifts

Scenario: Create a shift with power sign up
  Given I am logged into CAS as "alb64"
#  Given I am "Adam" "Bray"
	And I am on the homepage
  When I follow "Departments"
	When I follow "STC"
	Then I should see "test test blah"
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
	And I select "Bo Qu" from "shift_user_id"
	And I select "Io" from "shift_location_id"
	When I press "Submit"
	Then I should see "Successfully created shift."
	
#Scenario: Remove a shift
#e  Given I am logged into CAS as "alb64"

