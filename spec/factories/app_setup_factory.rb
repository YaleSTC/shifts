FactoryGirl.define do
  factory :app_config, class: AppConfig do
    ldap_host_address "directory.yale.edu"
    created_at "2009-07-09 18:39:41"
    ldap_base "ou=People,o=yale.edu"
    updated_at "2009-07-09 18:39:41"
    ldap_port "389"
    auth_types "CAS"
    ldap_login "uid"
    footer 'Certifying authority: Adam Bray, Asst. Manager, Student Technology<br/>Last modified: Wed Feb 28 00:17:00 EST 2007'
    ldap_last_name "sn"
    ldap_email "mail"
    ldap_first_name "givenname"
    mailer_address "yale.edu"
    admin_email "adam.bray@yale.edu"
  end

  factory :department do
    name "SDMP"
    # admin_permission is set automatically in the model before hook
    # DepartmentConfig are set automatically through DepartmentObserver Class
    # So are three built-in categories: Shifts, Punch Clocks and Miscellaneous
    # A Default Calendar is created too, named "#{department.name} Default Calendar"
    
    # we can safely assume we only have one department ever
    # Default to existing Department
    initialize_with {Department.where(name: name).first_or_initialize}
  end



  factory :category do # payform category
    department
    sequence(:name){|n| "Magic category #{n}"}
    active true
    built_in "f"

    # Default to existing category
    initialize_with {Category.where(name: name).first_or_initialize}
  end

  factory :role do
    department
    name "ordinary_role"
    
    # Default to existing role
    initialize_with {Role.where(name: name).first_or_initialize}

    # Give Role all signup and view permissions of all Loc Groups before saving to Database
    # Not executed if factory is called with #build
    before :create do |role|
      LocGroup.all.each do |lg|
        role.permissions += [lg.view_permission, lg.signup_permission]
      end
    end

    factory :admin_role do
      name "admin_role"
      # Give admin_role the admin permission of all loc groups before saving to Database
      # Not executed if factory is called with #build
      before :create do |role|
        LocGroup.all.each do |lg|
          role.permissions << lg.admin_permission
        end
        role.permissions << role.department.admin_permission
      end
    end
  end



  # As long as we only use CAS, we shouldn't need to think about Authlogic
  # UserSessions, just CAS
  #
  # factory :user_session do
  #   login "csw3"
  # end


  # DepartmentConfig is automatically created by the DepartmentObserver class
  # after creating a department (???)
  #
  # factory :department_configs, class: DepartmentConfig do
  #   # id "1"
  #   department
  #   schedule_start "900"
  #   schedule_end "1700"
  #   time_increment "15"
  #   grace_period "7"
  #   created_at "2009-06-22 17:27:52"
  #   day "6"
  #   end_of_month false
  #   monthly false
  #   unscheduled_shifts true
  #   updated_at "2009-06-22 17:27:52"
  #   weekend_shifts true
  #   warning_weeks "2"
  #   description_min "7"
  #   reason_min "7"
  #   printed_message  "This payform has already been printed and may no longer be edited by you.\n If there is a problem that needs to be addressed, please talk to the administration."
  #   reminder_message "Please remember to submit your payform for this week."
  #   warning_message "You have not submitted payforms for the weeks ending on the following dates:\n \n@weeklist@\n Please submit your payforms. If some of the weeks listed are weeks during which you did not work, please just submit a blank payform."
  # end


  # UserConfig is automatically created by the UserObserver class
  # after creating a user (???)
  # factory :user_config, class: UserConfig do
  #   # association :user, factory: :admin
  #   default_dept 1
  #   view_loc_groups 1
  #   view_week "whole_period"
  #   watched_data_objects ""
  # end

end
