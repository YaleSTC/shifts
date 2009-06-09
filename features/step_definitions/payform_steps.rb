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

Given /^I have the following payform items:$/ do |table|
  table.hashes.each do |row|
    c = Category.create!(:name => row[:category])
    u = User.find_by_login(row[:user_login])
    @payform_item = PayformItem.create!(:hours => row[:hours].to_f, :description => row[:description], :category_id => c.id, :user_id => u.id)
    @payform_item
  end
end

