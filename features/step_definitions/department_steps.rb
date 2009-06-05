Given /^I have a user named "([^\"]*)" in the department "([^\"]*)" with login "([^\"]*)"$/ do |name, department, login|
  user = User.new(:login => login, :name => name)
  user.departments << Department.find_by_name(department)
  user.save!
end