Given /^I have roles named "(.+)"$/ do |role_list|
  role_list.split(/\W/).map { |role| Role.create(:name => role) }
end

Given /^I have a user named (.+), netid (.+)$/ do |name, netid|
  User.create!(:name => name, :netid => netid)
end

Given /^I have no (.+)$/ do |class_name|
  class_name.classify.constantize.delete_all
end

Then /^I should have ([0-9]+) (.+)$/ do |count, class_name|
  class_name.classify.constantize.count.should == count.to_i
end

