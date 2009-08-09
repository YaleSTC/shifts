Feature: Shift admin manages shifts
  In order to manage shifts
  As a shifts admininistrator
  I want to be able to create, assign, and destroy shifts
@passing
Scenario: Create a shift with power sign up
  Given I am logged into CAS as "ad12"
  And I am on the homepage
  And I follow "Shifts"
  Then I should see "Add a Shift"
  When I follow "Add a Shift"
  And I select "2010" from "shift[start(1i)]"
  And I select "January" from "shift[start(2i)]"
  And I select "18" from "shift[start(3i)]"
  And I select "09" from "shift[start(4i)]"
  And I select "00" from "shift[start(5i)]"
  And I select "2010" from "shift[end(1i)]"
  And I select "January" from "shift[end(2i)]"
  And I select "18" from "shift[end(3i)]"
  And I select "10" from "shift[end(4i)]"
  And I select "00" from "shift[end(5i)]"
  And I select "Harry Potter" from "shift_user_id"
  And I select "Diagon Alley" from "shift_location_id"
  And I check "shift[power_signed_up]"
  When I press "Submit"
  Then I should see "Successfully created shift."

Scenario: Destroy a shift
  Given I am logged into CAS as "ad12"
  And I am on the homepage
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
  And I select "Harry Potter" from "shift_user_id"
  And I select "Diagon Alley" from "shift_location_id"
  When I press "Submit"
  Then I should see "Successfully created shift."
  When I follow "Shifts"
  And I follow "Destroy"
  Then I should see "Successfully destroyed shift."

