class AppConfig < ActiveRecord::Base

  def login_options_array
    self.login_options.split(', ')
  end


end
