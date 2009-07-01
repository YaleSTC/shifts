Given /^I had a shift yesterday$/ do
creation_time = (Time.now - 3.days)
start_time = (Time.now - 1.day)
end_time = (Time.now - 22.hours)
shift_taken = (Time.now - 2.days)

  TimeSlot.create!(:location_id => @department.locations.first,
                   :start => start_time,
                   :end => end_time,
                   :created_at => creation_time)

  this_shift = Shift.new(:start => start_time, :end => end_time,
                        :user_id => @user.id, :location_id => @department.locations.first,
                        :scheduled => true, :created_at => shift_taken,
                        :updated_at => shift_taken)
  this_shift.save_without_validation!

  Report.create!(:shift_id => this_shift.id,
                 :arrived => start_time,
                 :departed => end_time,
                 :created_at => start_time,
                 :updated_at => end_time)

end

Given /^"([^\"]*)" has a shift tomorrow$/ do |name|
user = User.find(:first, :conditions => {:first_name => name.split.first, :last_name => name.split.last})

creation_time = (Time.now - 3.days)
start_time = (Time.now + 1.day)
end_time = (Time.now + 26.hours)
shift_taken = (Time.now - 1.day)

  TimeSlot.create!(:location_id => @department.locations.first,
                   :start => start_time,
                   :end => end_time,
                   :created_at => creation_time)

  Shift.create!(:start => start_time, :end => end_time,
                :user_id => user.id, :location_id => @department.locations.first,
                :scheduled => true, :created_at => shift_taken,
                :updated_at => shift_taken)
end

Given /^today is not Sunday$/ do
  Date::DAYNAMES[Date.today.wday].should_not == "Sunday"
end


Given /^I have a LocGroup named "([^\"]*)" with location "([^\"]*)"$/ do |loc_group_name, location|
  loc_group = LocGroup.find_by_name(loc_group_name)
  Location.create!(:name => location, :short_name => location, :loc_group_id => loc_group.id, :max_staff => 2, :min_staff => 1, :priority => 1)

end

Then /^the page should indicate that I am in the department "([^\"]*)"$/ do |department|

  # ATTN: the dev team should choose one of the following lines and use it.
  # Use the first line if we want to have something like "Current department: STC" on the page
  # that indicates the current department.  Use the second line if we want a menu with links
  # to different departments, except the current department will be displayed but is not
  # a clickable link (which indicates that we're currently in that department)
#  response.should contain("Current department: #{department}")

  response.should_not have_selector("a", :content => department)
end

Then /^I should see all the days of the week$/ do
#  days_of_week = ["Sunday", "Monday", "Tuesday",
#                  "Wednesday", "Thursday", "Friday", "Saturday"]
  Date::DAYNAMES.each do |day|
    response.should contain(day)
  end
end

Then /^I should not see all the days of the week$/ do
a = Date.today.wday
c = {1=>"Monday", 2 => "Tuesday", 3 => "Wednesday", 4 => "Thursday", 5 => "Friday", 6=> "Saturday", 7 => "Sunday"}


  Date::DAYNAMES.each.except(a) do |day|
    response.should_not contain(day)
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

Then /^I should be able to select "([^\"]*)" as a time$/ do |time|
  select_time(time)
#  assert_select(time)
  assert_response :success
end

Then /^I should notbe able to select "([^\"]*)" as a time$/ do |time|
  lambda {select_time(time)}.should raise_error
#  save_and_open_page
#  assert_response :failure
end

Given /^"([^\"]*)" has a current payform$/ do |user_name|
  user = User.find(:first, :conditions => {:first_name => user_name.split.first, :last_name => user_name.split.last})
  Payform.create!(:date => 4.days.from_now, :user_id => user, :department_id => user.departments.first)
end

Given /^"([^\"]*)" has the following current payform items?$/ do |user_name, table|
  user = User.find(:first, :conditions => {:first_name => user_name.split.first, :last_name => user_name.split.last})
  table.hashes.each do |row|
    category = Category.find_by_name(row[:category])
    PayformItem.create!(:category_id => category,
                        :user_id => user,
                        :hours => row[:hours].to_f,
                        :description => row[:description],
                        :date => Date.today,
                        :payform_id => Payform.first)
  end
end

When /^I (.+) the "([^\"]*)" category$/ do |action, category|
# action is either enable or disable
  setting =
    case action
      when /enable/
        true
      when /disable/
        false
      else
        raise("The action must be either enable or disable")
      end
  Category.find_by_name(category).update_attribute(:active, setting)
end

