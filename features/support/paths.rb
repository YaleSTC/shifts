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
    when /that_shift page/
      shift_path(Shift.find(@that_shift))
    when /the user settings page/
      edit_user_config_path(UserConfig.find_by_user_id(@user.id))
    when /the Application Settings page/
      application_settings_path
    when /the department settings page for the "([^\"]*)" department/
      edit_department_config_path(Department.find_by_name($1))
    when /the dashboard/
      url_for(:controller => 'dashboard', :action => 'index')
    when /CAS/
      "https://secure.its.yale.edu/cas/login"
    when /the data types page/i
      data_types_path
    when /the data objects page/i
      data_objects_path
    when /the categories page for the "([^\"]*)" department/
      department_categories_path(Department.find_by_name($1))
    when /the login page/
      url_for(:controller => 'user_sessions', :action => 'new')
    when /the page for the user "([^\"]*)"/
      edit_user_path(User.find_by_login($1))
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

