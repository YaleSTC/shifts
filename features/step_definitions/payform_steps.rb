Given /^I am user "([^\"]*)"$/ do |login|
  @user = User.find_by_login(login)
end

Given /^I have the following categories: "([^\"]*)"$/ do |categories|
  categories.split(", ").each do |category_name|
    Category.create!(:name => category_name, :department_id => @user.departments[0].id)
  end
end

Given /^I have a payform for the week "([^\"]*)"$/ do |week|
  date = week.to_date
  @payform = Payform.create!(:date => date,
                             :user_id => @user.id,
                             :department_id => @user.departments[0].id)
end

Given /^I have the following payform items$/ do |table|
  table.hashes.each do |row|
    category = Category.find_by_name(row[:category])
    user = User.find_by_login(row[:user_login])
    PayformItem.new(:category_id => category.id,
                    :user_id => user.id,
                    :hours => row[:hours].to_f,
                    :description => row[:description])
  end
end

Then /^payform item ([0-9]+) should be a child of payform item ([0-9]+)$/ do |id_1, id_2|
  payform_item_1 = PayformItem.find(id_1.to_i)
  payform_item_2 = PayformItem.find(id_2.to_i)
  payform_item_2.payform_item_id.should == payform_item_1.id
end

Then /^payform item ([0-9]+) should have attribute (.+) "([^\"]*)"$/ do |id, attribute, expected|
  payform_item = PayformItem.find(id.to_i)
  attribute_constant = attribute.constantize
  payform_item.attribute_constant.should match(expected)
end

