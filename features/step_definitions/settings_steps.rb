Then /^the page should indicate that I am in the department "([^\"]*)"$/ do |department|

  # ATTN: the dev team should choose one of the following lines and use it.
  # Use the first line if we want to have something like "Current department: STC" on the page
  # that indicates the current department.  Use the second line if we want a menu with links
  # to different departments, except the current department will be displayed but is not
  # a clickable link (which indicates that we're currently in that department)
  response.should contain("Current department: " + department)

  response.should_not have_selector("a", :content => department)
end

