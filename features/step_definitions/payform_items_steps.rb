Given /^I am a payform administrator$/ do
  @current_user = User.new
  #this needs to be changed once we have payform administrator role/permission
  @current_user = Permission.all
end

Given /^I have a category "([^\"]*)"$/ do |category|
  @category = Category.create!(:name => category, :id => 1, :active => true)
end

