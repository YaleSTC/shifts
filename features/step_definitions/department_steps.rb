Given /^I have a user named "([^\"]*)" in the department "([^\"]*)" with netid "([^\"]*)"$/ do |name, department, netid|
  @department = department
  @netid = netid
  a = User.new(:name => name, :netid => netid)
  a.departments << Department.find_by_name(department)
  a.save
end

