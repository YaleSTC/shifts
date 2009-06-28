Feature: Restrictions test
In order to make restrictions
As a superuser
I want to be able to create, delete, and edit restrictions on shifts

Scenario Outline: Time limit
Given I have a time limit restriction for <res-hours> hours <res-minutes> minutes
Given this restriction expires <res-expiration>
# Given this restriction applies <res-department_locations_locgroups>
Given I am "Adam" "Bray"
Given I am on the homepage
When I follow "STC"
When I follow "Shifts"
When I follow "Power sign up"
And I select "<year>" from "shift_start_1i"
And I select "<month>" from "shift_start_2i"
And I select "<s_date>" from "shift_start_3i"
And I select "<s_24hours>" from "shift_start_4i"
And I select "<s_min>" from "shift_start_5i"
And I select "<year>" from "shift_end_1i"
And I select "<month>" from "shift_end_2i"
And I select "<e_date>" from "shift_end_3i"
And I select "<e_24hours>" from "shift_end_4i"
And I select "<e_min>" from "shift_end_5i"
And I select "Michael Libertin" from "shift_user_id"
And I select "Io" from "shift_location_id"
And I press "Submit"
Then I should see "<validity>"

Scenarios: Shift signup successful because under time limit, before expiration

|res-hours|res-minutes|res-expiration       |year|month|s_date|s_24hours|s_min|e_date|e_24hours|e_min|validity|
|6        |00         |"indefinitely"       |2009|11   |10    |13       |00   |10    |15       |00   |valid   |
|2        |45         |"indefinitely"       |2009|11   |10    |14       |00   |10    |16       |30   |valid   |
|5        |00         |"2009-12-12 12:00:00"|2009|10   |12    |20       |12   |13    |02       |16   |valid   |
|4        |30         |"2010-01-12 12:20:15"|2010|01   |12    |08       |00   |12    |12       |20   |valid   |

Scenarios: Shift signup successful because over time limit, past expiration

|res-hours|res-minutes|res-expiration       |year|month|s_date|s_24hours|s_min|e_date|e_24hours|e_min|validity|
|2        |00         |"2009-12-10 18:00:00"|2010|01   |11    |14       |00   |11    |20       |00   |valid   |
|4        |37         |"2010-04-15 22:30:00"|2010|04   |15    |22       |31   |16    |04       |00   |valid   |         
|8        |00         |"2010-12-20 16:00:00"|2010|12   |21    |01       |00   |21    |12       |00   |valid   |          
|5        |00         |"2009-11-23 12:25:00"|2009|12   |01    |12       |00   |01    |20       |00   |valid   |       

Scenarios: Shift signup successful because under time limit, past expiration

|res-hours|res-minutes|res-expiration       |year|month|s_date|s_24hours|s_min|e_date|e_24hours|e_min|validity|
|2        |00         |"2010-02-22 22:10:00"|2010|03   |15    |08       |00   |15    |09       |00   |valid   |
|4        |37         |"2010-04-17 12:28:00"|2010|04   |20    |12       |00   |20    |16       |36   |valid   |          
|8        |00         |"2009-12-10 12:00:00"|2009|12   |12    |14       |32   |12    |16       |00   |valid   |          
|5        |00         |"2009-10-11 13:30:00"|2009|10   |11    |20       |00   |12    |02       |00   |valid   |

Scenarios: Shift signup unsucessful because before expiration, over time limit

|res-hours|res-minutes|res-expiration       |year|month|s_date|s_24hours|s_min|e_date|e_24hours|e_min|validity|
|2        |00         |"2009-12-12 12:00:00"|2009|12   |10    |12       |00   |10    |15       |00   |invalid |
|4        |37         |"2009-12-12 12:00:00"|2009|12   |12    |05       |00   |12    |09       |38   |invalid |          
|8        |00         |"2010-02-18 23:00:00"|2010|01   |14    |23       |00   |15    |10       |00   |invalid |          
|5        |00         |"2010-05-22 14:22:01"|2010|05   |22    |09       |00   |22    |14       |22   |invalid |

#Scenario Outline: Sub requests
#Given I have a sub request restriction for <subs> sub requests
#Given this restriction expires <expiration>
#When 

#Scenario Outline: 
