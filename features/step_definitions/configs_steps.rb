Given /^"([^\"]*)" had a shift yesterday in "([^\"]*)"$/ do |name, location|
  user = User.find(:first, :conditions => {:first_name => name.split.first, :last_name => name.split.last})

  creation_time = ((Date.today - 3.days).to_time + 13.hours)
  start_time = ((Date.today - 1.day).to_time + 13.hours)
  end_time = ((Date.today - 1.day).to_time + 15.hours)
  shift_taken = (Time.now - 2.days)
  loc = Location.find_by_name(location).id

  TimeSlot.create!(:location_id => loc,
                   :start => start_time,
                   :end => end_time,
                   :created_at => creation_time)

  this_shift = Shift.new(:start => start_time, :end => end_time,
                        :user_id => user.id, :location_id => loc,
                        :scheduled => true, :created_at => shift_taken,
                        :updated_at => shift_taken)
  this_shift.save_without_validation!

  Report.create!(:shift_id => this_shift.id,
                 :arrived => start_time,
                 :departed => end_time,
                 :created_at => start_time,
                 :updated_at => end_time)

end

Given /^I have a shift tomorrow in "([^\"]*)"$/ do |location|


  creation_time = (Time.now - 3.days)
  start_time =  ((Date.today + 1.day).to_time + 13.hours)
  end_time =  ((Date.today + 1.day).to_time + 15.hours)
  shift_taken = (Time.now - 1.day)

  loc = Location.find_by_name(location).id

  TimeSlot.create!(:location_id => loc,
                   :start => start_time,
                   :end => end_time,
                   :created_at => creation_time)

  Shift.create!(:start => start_time, :end => end_time,
                :user_id => @current_user.id, :location_id => loc,
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

  # the following code checks to see that the select box has the correct department selected
  field_with_id("chooser_dept_id").value.should == [Department.find_by_name(department).id.to_s]
end

Then /^I should see all the days of the week$/ do
#  days_of_week = ["Sunday", "Monday", "Tuesday",
#                  "Wednesday", "Thursday", "Friday", "Saturday"]
  Date::DAYNAMES.each do |day|
    response.should contain(day)
  end

  yesterday = Date.yesterday.to_s(:Day)
  response.should contain(yesterday)
end

Then /^I should see "([^\"]*)" on the schedule$/ do |message|
  tomorrow = Date.tomorrow.to_s(:Day)
  yesterday = Date.yesterday.to_s(:Day)

  message = yesterday if message == "yesterday"
  message = tomorrow if message == "tomorrow"

  assert_select("div.time_table_updated") do |div|
    div.should contain(message)
  end
end

Then /^I should not see "([^\"]*)" on the schedule$/ do |message|
  tomorrow = Date.tomorrow.to_s(:Day)
  yesterday = Date.yesterday.to_s(:Day)

  message = yesterday if message == "yesterday"
  message = tomorrow if message == "tomorrow"

  assert_select("div.time_table_updated") do |div|
    div.should_not contain(message)
  end
end

Then /^I should see "([^\"]*)" in the footer$/ do |message|
  assert_select("p.footer") do |div|
    div.should contain(message)
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

Given /^"([^\"]*)" has a current payform$/ do |user_name|
  user = User.find(:first, :conditions => {:first_name => user_name.split.first, :last_name => user_name.split.last})
  period_date = Payform.default_period_date(Date.today, @department)
  Payform.create!(:date => period_date, :user_id => user, :department_id => user.departments.first)
end

Given /^"([^\"]*)" has the following current payform items?$/ do |user_name, table|
  user = User.find(:first, :conditions => {:first_name => user_name.split.first, :last_name => user_name.split.last})
  table.hashes.each do |row|
    category = Category.find_by_name(row[:category])

      p = Payform.build(user.departments.first, user, Date.today)

    PayformItem.create!(:category_id => category,
                        :user_id => user,
                        :hours => row[:hours].to_f,
                        :description => row[:description],
                        :date => Date.today,
                        :payform_id => p.id)
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

Then /^I should have a (.+) named "([^\"]*)"$/ do |object, name|
  if object =~ /user/
    user = User.find(:first, :conditions => {:first_name => name.split.first, :last_name => name.split.last})
    user.should_not be_nil
  else
    object.classify.constantize.find_by_name(name).should_not be_nil
  end
end

Then /^the department "([^\"]*)" should have a department_config$/ do |department|
  Department.find_by_name(department).department_config.should_not be_nil
end

Then /^the "([^\"]*)" should be "([^\"]*)"$/ do |attribute, value|
  @appconfig.send(attribute.to_s).to_s.should == value.to_s
end

