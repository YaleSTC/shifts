Feature: Regular user logs into a shift
	As a regular user
	I want to log into a shift
	So that I can begin updating my report

Scenario: User logged in
  Given I am logged into apps with netid "bq9" in department "STC"
  And I am on shifts
  Then I should see "Bo Qu"
  And I should see "bq9"

Scenario: Log into a blank report
	Given I am logged into apps with netid "bq9" in department "STC"
	And I am not logged into a shift report
	When I follow "Shift"
	And I follow "Sign in to a blank report"
	Then I should see a list of clusters
	And when I follow "Technology Troubleshooting Office"
	Then I should see a shift report for "Technology Troubleshooting Office"
	And my shift report should have one comment

Scenario: Fail to log into a second report
	Given I am logged into apps
	And I am logged into a shift report
	When I follow "Shift"
	And I follow "Sign in to a blank report"
	Then I should see "You are already signed into a shift!"
	And I should be on the shift page

