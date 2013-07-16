When /^I sign into an unscheduled shift in "([^\"]*)"$/ do |location|
  visit shifts_path
  click_link "Start an unscheduled shift"
  select(location, :from => "Location")
  click_button "Submit"
end

Given /^"([^\"]*)" are only in the department "([^\"]*)"$/ do |users_list, dept|
  department = Department.find_by_name(dept)
  department.should_not be_nil
  users_list.split(", ").each do |name|
    user = User.find(:first, :conditions => {:first_name => name.split.first, :last_name => name.split.last})
    user.should_not be_nil
    user.departments = []
    user.departments << department
    user.save!
  end
end

