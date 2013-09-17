@roles
@passing
Feature: Roles test

In order to create and assign roles
As an admin
I want to be able to create, delete, edit, and assign roles

Scenario Outline: Seeing the roles page
Given I am "<user>"
And I am on the roles page
Then I <shouldornot> see "New Role"
And I <shouldornot> see "Show All Roles"
And I <shouldornot2> see "Access denied"

Scenarios: Not being able to because not an admin user

|user            |shouldornot|shouldornot2|
|Harry Potter    |should not |should      |
|Hermione Granger|should not |should      |
|John Arbuckle   |should not |should      |
|Every Man       |should not |should      |
|Argus Filch     |should not |should      |

Scenarios: Being able to because is logged in as admin user

|user            |shouldornot|shouldornot2|
|Albus Dumbledore|should     |should not  |
|Horace Slughorn |should     |should not  |

Scenario Outline: Seeing the create a new role page

Given I am "<user>"
And I am on the new role page
Then I <shouldornot> see "New Role"
And I <shouldornot> see "Permissions"
And I <shouldornot2> see "Access denied"

Scenarios: Not being able to because not an admin user

|user            |shouldornot|shouldornot2|
|Harry Potter    |should not |should      |
|Hermione Granger|should not |should      |
|John Arbuckle   |should not |should      |
|Every Man       |should not |should      |
|Argus Filch     |should not |should      |

Scenarios: Being able to because is logged in as admin user

|user            |shouldornot|shouldornot2|
|Albus Dumbledore|should     |should not  |
|Horace Slughorn |should     |should not  |


Scenario Outline: Create a new role as an admin

Given I am "<user>"
And I am on the new role page
When I fill in "Name" with "Assistant Boss"
And I choose "Inside of Hogwarts signup"
And I choose "Outside of Hogwarts signup"
And I press "Create"
Then I should see "Successfully created role."
And I should have 2 roles.

Scenario Outline: Assigning roles via edit user

Given I am "<superuser>"
Given I have a role named "Assistant Boss" with permission "Inside of Hogwarts signup" in the department "Hogwarts"
Given the role named "Assistant Boss" has permission "Outside of Hogwarts signup"
And I am on the list of users
When I follow "<login>"
Then I should see "Edit User"
And I should see "Roles"
And I should see "Assistant Boss"

#Scenarios: Successfully assigning some roles

#|superuser       |login|firstname|lastname|email             |
#|Albus Dumbledore|hp123|Harry    |Potter  |hp123@hogwarts.edu|
#|Horace Slughorn |hp123|Harry    |Potter  |hp123@hogwarts.edu|

