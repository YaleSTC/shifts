# This will guess the User class
FactoryGirl.define do
  factory :app_configs, class: AppConfig do
    ldap_host_address "directory.yale.edu"
    created_at "2009-07-09 18:39:41"
    ldap_base "ou=People,o=yale.edu"
    updated_at "2009-07-09 18:39:41"
    # id "1"
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
    name "CCT SDMP"
    admin_permission_id "21"
    payforms_permission_id "22"
    shifts_permission_id "23"
  end

  factory :loc_group, class: LocGroup do
    department_id "1"
    name "Outside of Hogwarts"
    view_perm_id "111"
    signup_perm_id "112"
    admin_perm_id "113"
  end

  factory :location do
    name "Jurassic Park Pets"
    short_name "JPP"
    description "pets that live in Jurassic Park"
    category
    max_staff 2
    min_staff 1
    priority 1
    active true
    loc_group_id 1
  end

  factory :category do
    name "Magic"
    active true
    department_id 1
    built_in "f"
  end
  # factory :user_session do
  #   login "csw3"
  # end
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

  factory :user_configs, class: UserConfig do
    association :user, factory: :admin
    default_dept 1
    view_loc_groups 1
    view_week "whole_period"
    watched_data_objects ""
  end

  factory :admin, class: User do
    id 1
    login "ad12"
    first_name "Albus"
    last_name "Dumbledore"
    nick_name "Albus"
    email "ad12@hogwarts.edu"
    auth_type "CAS"
    # crypted_password "72065f776f0902c24d4a9f7b2803f58ba7e22829ce90efbb691eb803aa25d6e6f995b9ae4b17f45e10ce6aa02c6853ec26a773c645cadc8f23206e7efbaa734c"
    # password_salt "gDVImevY5D5G02T9cb3x"
    superuser true
    default_department_id 1
  end

end