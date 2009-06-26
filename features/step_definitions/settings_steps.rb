Given /^I have a shift yesterday$/ do
  Shift.create!(:start => Date.yesterday + " 1PM", :end => Date.yesterday + " 3 PM",
                :user_id => @user, :location_id => @department.locations.first,
                :scheduled => true)
end

Given /^today is not Sunday$/ do``
  Date::DAYNAMES[Date.today.wday].should_not == "Sunday"
end

Given /^I have a LocGroup named "([^\"]*)" with location "([^\"]*)"$/ do |loc_group_name, location|
  loc_group = LocGroup.create!(:name => loc_group_name, :department_id => @department.id)
  Location.create!(:name => location, :short_name => location, :loc_group_id => loc_group.id, :max_staff => 2, :min_staff => 1, :priority => 1)
end

Then /^the page should indicate that I am in the department "([^\"]*)"$/ do |department|

  # ATTN: the dev team should choose one of the following lines and use it.
  # Use the first line if we want to have something like "Current department: STC" on the page
  # that indicates the current department.  Use the second line if we want a menu with links
  # to different departments, except the current department will be displayed but is not
  # a clickable link (which indicates that we're currently in that department)
  response.should contain("Current department: #{department}")

  response.should_not have_selector("a", :content => department)
end

Then /^I should see all the days of the week$/ do
#  days_of_week = ["Sunday", "Monday", "Tuesday",
#                  "Wednesday", "Thursday", "Friday", "Saturday"]
  Date::DAYNAMES.each do |day|
    response.should contain(day)
  end
end

When /^I log out$/ do
  # This is a bad way of doing a logout, but I don't know of any other way
  CASClient::Frameworks::Rails::Filter.fake("invalid_login")
end

Then /^I should be redirected$/ do
  response.should be_redirect
end

Then /^I should be redirected to (.+)$/ do |page_name|
  response.should redirect_to(path_to(page_name))
end

