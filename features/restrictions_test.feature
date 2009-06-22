Feature: Restrictions test
In order to make restrictions
As a superuser
I want to be able to create, delete, and edit restrictions on shifts

Scenario Outline: Time limit
Given I have a time limit restriction for <hours> hours <minutes> minutes
Given this restriction expires <expiration>
Given this restriction applies <department_locations_locgroups>
When I 


Scenario Outline: Sub requests
Given I have a sub request restriction for <subs> sub requests
Given this restriction expires <expiration>
When 

Scenario Outline: 
