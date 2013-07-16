Given /^I have a time limit restriction for ([0-9]+) hours ([0-9]+) minutes$/ do |hours, minutes|
  @restriction = Restriction.new
  @restriction.max_hours = hours
  @restriction.max_hours += minutes.to_i / 60.0
end

Given /^I have a sub request restriction for ([0-9]+) sub requests$/ do |max_subs|
  @restriction = Restriction.new
  @restriction.max_subs = max_subs
end

Given /^this restriction expires "([^\"]*)"$/ do |expiration|
  if expiration = "indefinitely" 
    @restriction.expires = nil
  else
    @restriction.expires = expiration
  end
end
