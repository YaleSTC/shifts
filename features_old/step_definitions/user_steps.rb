Given /^I have roles named "(.+)"$/ do |role_list|
  role_list.split(/\W/).map { |role| Role.create(name: role) }
end

Given /^the user with netid (.+) belongs to the department (.+)$/ do |netid, department|
  department = @department
  User.find_by_netid(netid).departments << @department
end

Given /^I have a department named "(.+)"$/ do |department|
  @department = Department.create!(name: department)
end

