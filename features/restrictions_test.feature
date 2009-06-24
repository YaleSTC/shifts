Feature: Restrictions test
In order to make restrictions
As a superuser
I want to be able to create, delete, and edit restrictions on shifts

Scenario Outline: Time limit
Given I have a time limit restriction for <res-hours> hours <res-minutes> minutes
Given this restriction expires <res-expiration>
# Given this restriction applies <res-department_locations_locgroups>
Given I am logged into CAS as "alb64"
Given I am on the homepage
When I follow STC
When I follow Shifts
When I follow Power sign up
And I select <year> from "shift_start_1i"
And I select <month> from "shift_start_2i"
And I select <start-date> from "shift_start_3i"
And I select <start-24-hours> from "shift_start_4i"
And I select "00" from "shift_start_5i"
And I select <year> from "shift_end_1i"
And I select <month> from "shift_end_2i"
And I select <end-date> from "shift_end_3i"
And I select <end-24-hours> from "shift_end_4i"
And I select "00" from "shift_end_5i"
And I select "Michael Libertin" from "shift_user_id"
And I select "Io" from "shift_location_id"
And I press submit
Then I should see <validity>

Scenarios: Shift signup successful because under time limit, before expiration

|res-hours|res-minutes|res-expiration|year|month|start_date|start-24-hours|end-date|end-24-hours|validity|
|6        |00         |
|
Scenarios: Shift signup successful because past expiration, over time limit

Scenario: Shift signup successful because past expiration, under time limit

Scenarios: Shift signup unsucessful because over time limit, during expiration



Scenario Outline: Sub requests
Given I have a sub request restriction for <subs> sub requests
Given this restriction expires <expiration>
When 

Scenario Outline: 
