class SessionsController < ApplicationController
  skip_before_filter :login_check

  def logout
    CASClient::Frameworks::Rails::Filter.logout(self)
  end

end
