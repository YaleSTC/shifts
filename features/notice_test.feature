Feature: Create notices

Scenario: Create a new notice
  Given I just got through CAS with the login "mpl36"
  And I go to the homepage
  And I follow "STC"
  And I go to new notices
  
  
  Then I should see "New Notice"
  
  And I fill in "notice_content" with "wibble wibble"
  
  And I uncheck "start_time_choice, date"
  And I check "start_time_choice_now"
  
  And I select "2004" from "notice_start_time_1i"
  And I choose "end_time_choice_indefinite"
  And I fill in "notice_content" with "wibble wibble"
  And I select "STC (department-wide)" from "department"
  And I press "Create"
  When I go to notices
  Then I should see "wibble wibble"
  And I should see "by Bob Qu"
  
  
