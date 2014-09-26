@data
@cw
Feature: data entries
  In order to manage data entries
  As a dept admin or regular user
  I want to be able to create and maintain data entries

  Background:
    Given I have a data type with name "Ring of Power", description "powerful", for the department "Hogwarts", with the following data fields
        | name     | display_type | values                                   |
        | Metal    | select_box   | Gold, Silver, Copper, Brass, Iron        |
        | Powers   | check_box    | Invisibility, The Force, Flight          |
        | Comments | text_area    |                                          |
        | Number   | text_field   | integer                                  |
    And I have a data object of data_type "Ring of Power", named "The One Ring", description "to rule them all, you know?", in location "Diagon Alley"

  Scenario: Add data entry from data object page (as a dept admin)
    Given I am "Harry Potter"
    And the user "Harry Potter" has permissions "Hogwarts dept admin"
    And I am on the data objects page
    When I follow "The One Ring"
    And I press "Add new data entry"
    And I check "Invisibility"
    And I check "Flight"
    And I put "1" in "Number"
    And I put "It drove Frodo mad." in "Comments"
    And I select "Gold" as the "Metal"
    And I press "Submit"

    Then I should see "Successfully created data entry."
    And I should see "#{Date.today}"
    And I should see "Gold"
    And I should see "Flight"
    And I should see "It drove Frodo mad."
    And I should see "1"

  Scenario: Add data entry from shifts page (as a regular user)
    Given I am "Harry Potter"
    And there is a scheduled shift:
        | start_time     | end_time       | location     | user         |
        | 12/25/2009 5pm | 12/25/2009 7pm | Diagon Alley | Harry Potter |

    And I am on the shifts page
    Then I should see "Diagon Alley, Fri, Dec 25 05:00 PM-07:00 PM"
    When I follow "Diagon Alley, Fri, Dec 25 05:00 PM-07:00 PM"
    And I follow "The One Ring"
    And I press "Add new data entry"

    And I select "Gold" as the "Metal"
    And I check "Invisibility"
    And I check "Flight"
    And I put "It drove Frodo mad." in "Comments"
    And I put "1" in "Number"
    And I press "Submit"

    Then I should see "Successfully created data entry."
    And I should see "#{Date.today}"
    And I should see "Gold"
    And I should see "Flight"
    And I should see "It drove Frodo mad."
    And I should see "1"

