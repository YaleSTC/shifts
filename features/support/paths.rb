module NavigationHelpers
  # Maps a name to a path. Used by the
  #
  #   When /^I go to (.+)$/ do |page_name|
  #
  # step definition in web_steps.rb
  #
  def path_to(page_name)
    case page_name
    
    when /the home\s?page/
      @appconfig = AppConfig.first
      root_path
    when /the list of users/
      department_users_path(@department)
    when /the list of departments/
      departments_path
    when /the page for the payform for the week "([^\"]*)"/i
      payform_path(Payform.where(:date =>$1.to_date).first)
    when /the payform for this week/
      go_payforms_path
    when /the payforms page/
      payforms_path
    when /shifts/
      shifts_path
    when /that_shift page/
      shift_path(Shift.find(@that_shift))
    when /the user settings page/
      edit_user_config_path(UserConfig.where:user_id => current_user.id).first)
    when /the Application Settings page/
      edit_app_config_path
    when /the department settings page/
      $department = @department
      edit_department_config_path(@department)
    when /the roles page/
      department_roles_path(:department_id => Department.find(@current_user.user_config.default_dept))
    when /the new role page/
      new_department_role_path(:department_id => Department.find(@current_user.user_config.default_dept))
    when /the dashboard/
      url_for(:controller => 'dashboard', :action => 'index')
    when /CAS/
      "https://secure.its.yale.edu/cas/login"
    when /the data types page/i
      data_types_path
    when /the data objects page/i
      data_objects_path
    when /the categories page for the "([^\"]*)" department/
      department_categories_path(Department.where(:name => $1).first)
    when /the login page/
        @appconfig = AppConfig.first
      url_for(:controller => 'user_sessions', :action => 'new')
    when /the page for the user "([^\"]*)"/
      edit_user_path(User.where(:login=> $1).first)
    # Add more mappings here.
    # Here is an example that pulls values out of the Regexp:
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