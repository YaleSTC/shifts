Given /^I am user "([^\"]*)"$/ do |login|
  @user = User.find_by_login(login)
end

Given /^I have the following categories: "([^\"]*)"$/ do |categories|
  categories.split(", ").each do |category_name|
    Category.create!(:name => category_name)
  end
end

Given /^I have a payform for the week "([^\"]*)"$/ do |week|
  date = week.to_date
  @payform = Payform.create!(:date => date,
                             :user_id => @user.id,
                             :department_id => @user.departments[0].id)
end

Given /^I have the following "([^\"]*)"$/ do |object, table|
  object_class = object.classify.constantize
  table.hashes.each do |hash|
    object_class.new(hash)
  end
end

