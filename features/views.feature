
Feature: Sidebars
  In order to make sure people see the correct side bars
  As an application admin, or regular user
  I want to see more choices when logged in as an admin

    Scenario:
        Given I am "Albus Dumbledore"
        And I am on the homepage
        Then I should see "Departments"
        And I should not see "Profiles"
        When I go to Shifts
        Then I should have a 
    
#    Example:
#        | user              |
#        | "Albus Dumbledore"|
#        | "Harry Potter"    |

