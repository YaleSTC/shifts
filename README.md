# Basic Guide to Shifts [![Code Climate](https://codeclimate.com/github/YaleSTC/shifts.png)](https://codeclimate.com/github/YaleSTC/shifts)
**Creator:** Adam Bray

**Original Contributors:**

* Kwabena Antwi-Boasiako
* AJ Espinosa
* Nathan Griffith
* Cassandra Kildow
* Ryan Laughlin
* Michael Libertin
* Aashish Manchanda
* Bob Qu
* Ben Somers
* Laura Tomas
* Harley Trung
* Wei Yan
* Derek Zhao

---

## 1. Introduction

Shifts is a program that allows the easy tracking of employees who work scheduled (and even unscheduled) hours in various locations and times. It also offers payform features, allowing automatic logging of when employees work shifts, with the option for adding addition hours worked outside of shifts.

There are two sections of the application, one for employees who work shifts, and another for administrators, who manage these employees (Note: administrators can use the application as both administrators and employees, allowing them to perform administrative duties on top of using payforms, shifts, etc.)

Let's begin by explaining some of the concepts of the application from an employee's point-of-view.

### Shift
A shift is a scheduled block of time. A shift specifically contains the following info:

* Who is working? (Each shift has one owner)
* When are they working? (Start and end time)
* Where are they working? (Each shift must be in a Location)

A shift basically gives ownership of a spot to an employee. They are responsible for working that shift. However, the program allows the option of the employee to file a sub request.

### Report
A shift report is created once a employee(user) signs in, and finalized when the user signs out. It consists of timestamped line items.  The first line item records the login IP address and the last logout IP address.  Every 10-15 minutes or so the logged-in employee is supposed to add line items to the report.

### Sub Request
When an employee files a sub request for a future scheduled shift, a request is emailed to the people that this employee inputs or everybody that is allowed to take that shift (a group email defined in the Location Group's settings). For example, if John (a senior tech) has filed a request for a sub for his shift in the 'technology troubleshooting office' location, the request is emailed to the address defined for the 'senior staff' Location Group. You would likely want to define this address to be a mailing list that sends to all the senior techs but not the junior techs.

### Locations
Locations are places where you have employees working. Examples might be a front desk, troubleshooting office, or computing cluster. Locations could even be for non-physical locations, where you have a defined staff working, such for tasks. For example, if you have staff who work on tasks such as an on-duty courier, you could define this as a location.

* Locations have the following properties:
* Name
* Short Name (Used in certain display contexts where name lengths should be shorter)
* Report Email Address (The email address to which reports are sent to. More will be said on reports later on)
* Priority (More on this in the later)
* Max and Min Staffing Desired

### Location Groups
Every Location must belong to exactly one location group. Location groups not only serve as logical groupings, but more importantly, are used for access control. Permissions for things like who can work where are set by location group. This may be explained best by exapmle:

Say you have two classes of employees, junior staff, and senior staff. You have four locations/positions where you regularly have staffing: a front desk, a courier, an assistant, and a supervisor. If you intend for the assistant and the supervisor shifts to only be staffed by senior staff, you would want to create two location groups. The first group would contain the 'front desk' and 'courier' locations, and the second group would contain the 'assistant' and 'supervisor' locations.

You could then define your groups such that only senior staff could sign up for, or work shifts in the 'assistant' and 'supervisor' locations.

Location groups have the following properties:

* Name
* Short Name
* Maximum Shift Length
* Minimum Shift Length
* Sub Request Email Address

### Time Slots
TODO: explains how time slots are used to allow shifts to be signup-able

## 2. Implementation

We will use Ruby on Rails terminology here to make easier to explain. Each of the headings below corresponds to a model name and its controller name in plural. We try to stick to the RESTful approach. Note that for some controllers (eg. subs controller) we do not need all 7 standard actions (index, new, create, edit, update, show, destroy) – try to keep the design simple by not including unnecessary actions and views. Sometimes additional actions are needed.

### Shift
* `new`: a shift sign-up page letting the user choose the start/end times and the location to work a shift in
	* (admin only) allow selecting users
* `create`: takes the submitted form and verify that request shift can be created.  Checking the following
	* is there a time slot open for that period
	* is there any constraint? E.g. shift too short/too long, the user is exceed the number of shift hours allowed, there is another location that is more important to work for during that time, etc
	* if a shift is legal, checks if it can be combined to another adjacent shift
* `edit` (loc group admin only): allows an admin to change the details of a shift
* `update`: similar to create with validation and saving
* `index`: show all shifts, maybe restricted to a location or loc group or department
* `destroy` (admin only): allows an admin to cancel a certain shift for another user

### Sub
(sub routing should be nested in shift)
	
* `new`: lets a user create a sub request
* `create`: validates and saves.
* `destroy` (loc group admin only): allows an admin to cancel a sub
* note that there is no editing of a sub. one should request an admin to delete it and create a new one

### Report
(report routing should be nested in shift)

* `new`: this is the sign in page, it shows the confirmation that the employee wants to log in
* `create`: as usual, redirected from new
* `show`: display all line items belonging to this report (line items have shift report id)
* there is no `index`/`edit`/`update`/`destroy`

### Location
* only a loc group admin can manage locations

### Loc Group
* only a department admin can manage loc groups
* `before_validation` hooks are used to create/update/destroy permissions associated to creating/updating/destroying a loc group (signup vs view-only vs admin)

### Department/User
* only a superuser can manage departments and all users
* `before_validation` hooks are used to create/update/destroy an associated permission

### User
* only superuser can manage all users or department admin can manage all users in that department

### Role
* `new`: let the admin create a new name and a selection of permissions associated to it
* only a department admin can manage roles

### Permission
* `index`: display all permissions pertaining to `current_department`
* no other CRUD actions necessary because permissions are only created indirectly (when a new log group or new department is created)

### Time Slot

TODO: A lot more is needed here.

## 3. Admin stuff

We have the following `before_filter` methods that allow us to perform authorization at controllers' level:

`require_superuser`
`require_department_admin`
`require_loc_group_admin`

## 4. Routing

Shallow routing is used but bear in mind form_for must be treated differently for new and edit. See code (eg. view code for loc group) for more information.

* `/departments`
	* list all departments (`require_superuser`)
* `/departments/users` (or `/users`)
	* list all users (`require_superuser`)
* `/departments/:department_id/*`
	* (`require_department_admin`)
	* asterisk here can be lots of things nested under a department such as roles, users, `loc_groups`, etc
* `/:department_name/*`
	* we can actually implement a check for this: if `department_name` is actually a real department name
	* we treat it just like `/departments/:department_id/`
	* thus we can have urls such as `/stc/users` or `/itg/roles` or `/stc/shifts` etc
* `/loc_groups/:loc_group_id/*`
	* (`require_loc_groug_admin`)


## CREDITS

Application icons provided by led24.de:  
<http://led24.de/iconset/> (LED Icon Set)
