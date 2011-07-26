class AppConfig < ActiveRecord::Base
  validates_presence_of :auth_types
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
