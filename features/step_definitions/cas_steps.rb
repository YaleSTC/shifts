Given /^I just got through CAS with the login "(.+)"$/ do |login|
  CASClient::Frameworks::Rails::Filter.fake(login)
    @current_user = User.find_by_login(login)
end

