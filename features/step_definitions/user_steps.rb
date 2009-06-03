Given /^I have roles named "(.+)"$/ do |role_list|
  role_list.split(/\W/).map { |role| Role.create(:name => role) }
end

Given /^I have a user named (.+), netid (.+)$/ do |name, netid|
  User.create!(:name => name, :netid => netid)
end

Given /^I have a department named "(.+)"$/ do |department|
  @department = Department.create!(:name => department)
end

