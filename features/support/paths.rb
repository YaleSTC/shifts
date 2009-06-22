module NavigationHelpers
  # Maps a name to a path. Used by the
  #
  #   When /^I go to (.+)$/ do |page_name|
  #
  # step definition in webrat_steps.rb
  #
  def path_to(page_name)
    case page_name

    when /the homepage/
      root_path
    when /the list of users/
      department_users_path(@department)
    when /the list of departments/
      departments_path
    when /the page for the payform for the week "([^\"]*)"/i
      payform_path(Payform.find_by_date($1.to_date))
    when /the payforms page/
      payforms_path
				when /shifts/
				  shifts_path
				when /notices/
      notices_path
    when /new notices/
      new_notices_path

    # Add more mappings here.
    # Here is a more fancy example:
    #
    #   when /^(.*)'s profile page$/i
    #     user_profile_path(User.find_by_login($1))

    else
      raise "Can't find mapping from \"#{page_name}\" to a path.\n" +
        "Now, go and add a mapping in #{__FILE__}"
    end
  end
end

World(NavigationHelpers)

