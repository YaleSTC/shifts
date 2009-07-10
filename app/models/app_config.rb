class AppConfig < ActiveRecord::Base
  validates_presence_of :auth_types

  LOGIN_OPTIONS = [
    # Displayed               stored in db
    ["Central Authentication Service (CAS)",      "CAS"],
    ["Internal Authentication",                   "authlogic"]
  ]

  def login_options
    self.auth_types.split(', ')
  end

  def auth_types=(login_options)
    login_options = login_options.split(', ') if login_options.class == String
    write_attribute(:auth_types, login_options.uniq.remove_blank.join(", "))
  end


end
