Given /^I have a user named "([^\"]*)" in the department "([^\"]*)" with login "([^\"]*)"$/ do |name, department, netid|
  user = User.new(:netid => netid, :name => name)
  user.departments << Department.find_by_name(department)
  user.save!
end

