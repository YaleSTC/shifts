Feature: Regular user logs into a shift
	As a regular user
	I want to log into a shift
	So that I can begin updating my report

Scenario: Log into an unscheduled shift
  Given I am logged into CAS as "studcomp"
    #Let us make studcomp the default regular user
	  And I am not logged into a shift
	  When I am on the homepage
	  And I follow "Here"
	  #"Here" refers to a link within a redirect error message
    And I follow "Shifts"
	  Then I should not see "Return to current shift"
	  When I follow "Start an unscheduled shift"
    And I select "TTO" from "shift_location_id"
	  And I press "Submit"
	  Then I should see "Unscheduled Shift"
	  And I should see "Successfully created shift."
	  When I press "Sign in"
	  Then I should see "Shift Report at the TTO"
	  #And my shift report should have 1 comment
	  #I do not know how the report thing works

#Scenario: Fail to log into a second shift
#This feature is not presently implemented
#  Given I am logged into CAS as "studcomp"
#  And I am logged into a shift
#  When I follow "Shifts"
#  And I follow "Start an unscheduled shift"
#	And I select "TTO" from "shift_location_id"
#	And I press "Submit"
#	Then I should see "You are already signed into a shift!"

Scenario: End shift
  Given I am logged into CAS as "studcomp"
  And I am on the homepage
  And I am logged into a shift
  When I follow "Here"
  And I follow "Shifts"
  Then I should see "Return to current shift"
  And I follow "Return to current shift"
  And I press "End shift"
  Then I should see "Successfully ended shift"

