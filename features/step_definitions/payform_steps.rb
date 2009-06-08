Given /^I am user "([^\"]*)" in department "([^\"]*)"$/ do |login, department|
  user = User.new(:login => login)
  user.departments << Department.find_by_name(department)
  user.save!
end

Given /^I have the following categories: "([^\"]*)"$/ do |categories|
  categories.split(", ").each do |category_name|
    Category.create!(:name => category_name)
  end
end

Given /^I have a payform for the week "([^\"]*)"$/ do |week|
  date = week.to_date
  #This has to be changed to make it consistent with creating a new payform
  @payform = Payform.new(:user_id => @user.id, :week => date)
end

