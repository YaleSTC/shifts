Given /^I just got through CAS with the login (.+)$/ do |login|
  CASClient::Frameworks::Rails::Filter.fake(login)
end

