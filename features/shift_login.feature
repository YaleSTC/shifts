@shift
Feature: Regular user logs into a shift
  As a regular user
  I want to log into a shift
  So that I can begin updating my report

    Background:
        Given I am "Harry Potter"
        And the user "Harry Potter" has permissions "Outside of Hogwarts signup"
@passing
@t
    Scenario: Log into an unscheduled shift
        Given I am not logged into a shift
        When I am on shifts page
        Then I should not see "Return to your current shift report"
        When I follow "Start an unscheduled shift"
        And I select "Diagon Alley" from "shift_location_id"
        And I press "Submit"
        Then I should see "Shift Report at the Diagon Alley"
        And I should see "Message Center for the Diagon Alley"
        
        When I fill in "report_item[content]" with "Hey, I am here!"
        And I press "Add this event"        
        #this step might fail if done at exactly the wrong moment 
        Then the current time should appear 
        And I should see "Hey, I am here!"

        When I go to the homepage
        And I follow "Start an unscheduled shift"
        And I select "Diagon Alley" from "shift_location_id"
        And I press "Submit"
        Then I should see "You can't sign into two shifts!"
        When I go to the homepage
        And I follow "Return to your current shift report"
        And I press "End shift"
        Then I should see "Successfully submitted report and updated payform."
        And "Harry Potter" should have 1 payform_item

    Scenario: Fail to log into a second shift
        Given there is a scheduled shift:
        | start_time     | end_time       | location     | user         |
        | 12/25/2009 5pm | 12/25/2009 7pm | Diagon Alley | Harry Potter |
        And "Harry Potter" signs in at "12/25/2009 5:10pm"
        And I am on shifts page
        And I follow "Start an unscheduled shift"
        And I select "Diagon Alley" from "shift_location_id"
        And I press "Submit"
        Then I should see "You are already signed into a shift!"
@passing
    Scenario: Sub Requests
        Given there is a scheduled shift:
        | start_time     | end_time       | location     | user         |
        | 12/25/2009 5pm | 12/25/2009 9pm | Diagon Alley | Harry Potter |
        And I am on the homepage
        Then I should see "Your Upcoming shifts"
        When I follow "Diagon Alley, Fri, Dec 25 05:00 PM-09:00 PM"
        And I follow "Request a sub for this shift"
        And I select "2009" from "sub_request[mandatory_start(1i)]"
        And I select "December" from "sub_request[mandatory_start(2i)]"
        And I select "25" from "sub_request[mandatory_start(3i)]"
        And I select "05" from "sub_request[mandatory_start(4i)]"
        And I select "PM" from "sub_request[mandatory_start(7i)]"
        And I select "2009" from "sub_request[mandatory_end(1i)]"
        And I select "December" from "sub_request[mandatory_end(2i)]"
        And I select "25" from "sub_request[mandatory_end(3i)]"
        And I select "06" from "sub_request[mandatory_end(4i)]"
        And I select "PM" from "sub_request[mandatory_end(7i)]"
        And I select "2009" from "sub_request[start(1i)]"
        And I select "December" from "sub_request[start(2i)]"
        And I select "25" from "sub_request[start(3i)]"
        And I select "05" from "sub_request[start(4i)]"
        And I select "PM" from "sub_request[start(7i)]"
        And I select "2009" from "sub_request[end(1i)]"
        And I select "December" from "sub_request[end(2i)]"
        And I select "25" from "sub_request[end(3i)]"
        And I select "09" from "sub_request[end(4i)]"
        And I select "PM" from "sub_request[end(7i)]"
        And I fill in "list_of_logins" with "hg9"
        And I fill in "Reason" with "I need to eat dinner"
        And I press "Create"
        Then I should see "Sub request was successfully created."
        
        When I follow "Logout"
        Given I am "Hermione Granger"
        And the user "Hermione Granger" has permissions "Outside of Hogwarts signup"
        And I am on the homepage
        Then I should see "Subs You Can Take"
        When I follow "Diagon Alley, Fri, Dec 25 05:00 PM-09:00 PM (I need to eat dinner)"
        And I follow "Take"
        And I press "Take this!"
        Then "Hermione Granger" should have "one" shift 
        And "Harry Potter" should have "no" shift 
