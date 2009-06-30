class SessionsController < ApplicationController
  before_filter CASClient::Frameworks::Rails::Filter
  skip_before_filter :login_or_register

  def login
    redirect_to root_url
  end

  def logout
    CASClient::Frameworks::Rails::Filter.logout(self)
  end

end
