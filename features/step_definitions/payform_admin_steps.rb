Given /^I am a payform administrator$/ do
  #this needs to be changed once we have payform administrator role/permission
end

Given /^I have a category "([^\"]*)"$/ do |category|
  @category = Category.create!(:name => category, :id => 1, :active => true)
end


Given /^I have the following payforms:$/ do |table|
  table.hashes.each do |row|
      d = row[:date]
      u = User.find_by_name(row[:user]).id
      @department_id = DepartmentsUser.find_by_user_id(u).department_id
      a = Payform.create!(:date => d , :department_id => @department_id, :user_id => u, :submitted => Time.now)
    end
end

Then /^I should see "([^\"]*)" under "([^\"]*)"$/ do |arg1, arg2|
  pending
end

