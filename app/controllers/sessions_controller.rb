class SessionsController < ApplicationController
  skip_before_filter :login_check

  def logout
    RubyCAS::Filter.logout(self)
  end

end
