Feature: Regular user logs into a shift
	As a regular user
	I want to log into a shift
	So that I can begin updating my report

Scenario: Log into an unscheduled shift, fail to log into a second
  Given I just got through CAS with the login "studcomp"
    #Let us make studcomp the default regular user
	  And I am not logged into a shift report
	  When I am on the homepage
	  And I follow "Here"
	  #"Here" refers to a link within a redirect error message
    And I follow "Shifts"
	  Then I should not see "Return to current shift"
	  When I follow "Start an unscheduled shift"
    When I select "TTO" from "shift_location_id"
	  When I press "Submit"
	  Then I should see "Unscheduled Shift"
	  Then I should see "TTO"
	  When I press "Create Report"
	  Then I should see "Shift Report at the TTO"
	  #And my shift report should have 1 comment
	  #I do not know how the report thing works
  #When I follow "Shifts"
  #Not adding this feature yet
    #And I follow "Start an unscheduled shift"
	  #When I select "TTO" from "shift_location_id"
	  #When I press "Submit"
	  #Then I should see "You are already signed into a shift!"
	  #And I should be on the shift page
	  #When I follow "STC"

