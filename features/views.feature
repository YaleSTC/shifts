
Feature: Sidebars
  In order to make sure people see the correct side bars
  As an application admin, or regular user
  I want to see more choices when logged in as an admin

Scenario Outline: See more choices when logged in as admin
Given I am logged into CAS as <user>
Given I am on the homepage
Then I <shouldornot> see <item>

Scenarios: Logged in as superuser

|user  |shouldornot|item       |
|"ad12"|should     |"Dashboard"|
|"ad12"|should     |"Hogwarts" |
|"ad12"|should     |"Users"    |
|"ad12"|should     |"Shifts"   |
|"ad12"|should     |"Payforms" |

Scenarios: Logged in as normal user

|user   |shouldornot|item         |
|"em123"|should     |"Dashboard"  |
|"em123"|should     |"Shifts"     |
|"em123"|should     |"Payforms"   |
|"em123"|should not |"Departments"|
|"em123"|should not |"Users"      |

Scenario Outline: See control panel on certain pages depending on how logged in
Given I am logged into CAS as <user>
Given I am on the homepage
When I follow <page>
Then I <shouldornot> see <item>


Scenarios: Logged in as admin

|user  |page      |shouldornot|item                 |
|"ad12"|"Shifts"  |should     |"Scheduling Options" |
|"ad12"|"Shifts"  |should     |"Schedule"           |
|"ad12"|"Shifts"  |should     |"Time Slots"         |
|"ad12"|"Shifts"  |should     |"Locations"          |
|"ad12"|"Shifts"  |should     |"Location Groups"    |
|"ad12"|"Shifts"  |should     |"Restrictions"       |
|"ad12"|"Shifts"  |should     |"Notices"            |
|"ad12"|"Shifts"  |should     |"Shift Report Links" |
|"ad12"|"Shifts"  |should     |"Export Schedule"    |
|"ad12"|"Shifts"  |should     |"Templates"          |
|"ad12"|"Shifts"  |should     |"Activate Templates" |
|"ad12"|"Shifts"  |should     |"View Options"       |
|"ad12"|"Shifts"  |should     |"Unscheduled Shifts" |
|"ad12"|"Shifts"  |should     |"Active Shifts"      |
|"ad12"|"Shifts"  |should     |"Data Objects"       |
|"ad12"|"Payforms"|should     |"Payform Admin"      |
|"ad12"|"Payforms"|should     |"View Payforms"      |
|"ad12"|"Payforms"|should     |"Submitted"          |
|"ad12"|"Payforms"|should     |"Approved"           |
|"ad12"|"Payforms"|should     |"Printed"            |
|"ad12"|"Payforms"|should     |"Print History"      |
|"ad12"|"Payforms"|should     |"Mass Add Jobs"      |
|"ad12"|"Payforms"|should     |"View Mass Jobs"     |
|"ad12"|"Payforms"|should     |"Punch Clocks"       |
|"ad12"|"Payforms"|should     |"Mass Punch Clocks"  |
|"ad12"|"Payforms"|should     |"E-mail Reminders"   |
|"ad12"|"Payforms"|should     |"Edit Categories"    |
|"ad12"|"Payforms"|should     |"Edit Configurations"|

Scenarios: Logged in as regular user

|user   |page      |shouldornot|item                 |
|"em123"|"Shifts"  |should not |"Scheduling Options" |
|"em123"|"Shifts"  |should not |"Time Slots"         |
|"em123"|"Shifts"  |should not |"Locations"          |
|"em123"|"Shifts"  |should not |"Location Groups"    |
|"em123"|"Shifts"  |should not |"Restrictions"       |
|"em123"|"Shifts"  |should not |"Notices"            |
|"em123"|"Shifts"  |should not |"Shift Report Links" |
|"em123"|"Shifts"  |should not |"Export Schedule"    |
|"em123"|"Shifts"  |should not |"Templates"          |
|"em123"|"Shifts"  |should not |"Activate Templates" |
|"em123"|"Shifts"  |should not |"View Options"       |
|"em123"|"Shifts"  |should not |"Unscheduled Shifts" |
|"em123"|"Shifts"  |should not |"Active Shifts"      |
|"em123"|"Shifts"  |should not |"Data Objects"       |
|"em123"|"Payforms"|should not |"Payform Admin"      |
|"em123"|"Payforms"|should not |"View Payforms"      |
|"em123"|"Payforms"|should not |"Submitted"          |
|"em123"|"Payforms"|should not |"Approved"           |
|"em123"|"Payforms"|should not |"Printed"            |
|"em123"|"Payforms"|should not |"Print History"      |
|"em123"|"Payforms"|should not |"Mass Add Jobs"      |
|"em123"|"Payforms"|should not |"View Mass Jobs"     |
|"em123"|"Payforms"|should not |"Punch Clocks"       |
|"em123"|"Payforms"|should not |"Mass Punch Clocks"  |
|"em123"|"Payforms"|should not |"E-mail Reminders"   |
|"em123"|"Payforms"|should not |"Edit Categories"    |
|"em123"|"Payforms"|should not |"Edit Configurations"|

