# == Schema Information
#
# Table name: app_configs
#
#  id                 :integer          not null, primary key
#  footer             :string(255)
#  auth_types         :string(255)
#  ldap_host_address  :string(255)
#  ldap_port          :integer
#  ldap_base          :string(255)
#  ldap_login         :string(255)
#  ldap_first_name    :string(255)
#  ldap_last_name     :string(255)
#  ldap_email         :string(255)
#  use_ldap           :boolean
#  mailer_address     :string(255)
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  calendar_feed_hash :string(255)
#  admin_email        :string(255)
#

class AppConfig < ActiveRecord::Base
  #commented out for now, maybe re-add later
  #validates_presence_of :auth_types
  validates_presence_of :mailer_address, :admin_email

  LOGIN_OPTIONS = [
    # Displayed               stored in db
    ["Central Authentication Service (CAS)",      "CAS"],
    ["Built-in Authentication",                   "built-in"]
  ]

  def login_options
    self.auth_types.split(', ')
  end

  def auth_types=(login_options)
    login_options = login_options.split(', ') if login_options.class == String
      write_attribute(:auth_types, login_options.uniq.remove_blank.join(', '))
  end


end
