Given /^I am user "([^\"]*)" in department "([^\"]*)"$/ do |login, dept_string|
  @user = User.new(:login => login)
  department = Department.find_by_name(department) || Department.create!(:name => dept_string)
  @user.departments << department
  @user.save!
end

Given /^I have the following categories: "([^\"]*)"$/ do |categories|
  categories.split(", ").each do |category_name|
    Category.create!(:name => category_name)
  end
end

Given /^I have a payform for the week "([^\"]*)"$/ do |week|
  date = week.to_date
  @payform = Payform.new(:date => date,
                         :user_id => @user.id,
                         :department_id => @user.departments[1].id)
end

