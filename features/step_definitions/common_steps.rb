Given /^I have no (.+)$/ do |class_name|
  class_name.classify.constantize.delete_all
end

Then /^I should have ([0-9]+) (.+)$/ do |count, class_name|
  class_name.classify.constantize.count.should == count.to_i
end

When /^I choose to view (.+)$/ do |department|
  visit path_to(department_users_path(@department))
end
