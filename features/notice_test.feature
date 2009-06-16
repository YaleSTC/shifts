Feature: Create notices

Scenario: Create a new notice
  Given I just got through CAS with the login "mpl36"
  And I go to new notices
  And I select "now" from "start_time_choice_now"
  And I select "indefinitely" from "end_time_choice_indefinite"
  And I fill in "notice_content" with "wibble wibble"
  And I select "STC (department-wide)" from "department"
  And I press "Create"
  When I go to notices
  Then I should see "wibble wibble"
  And I should see "by Bob Qu"
  
  
