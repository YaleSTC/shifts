class UserSessionsController < ApplicationController
  skip_before_filter :login_or_register
  skip_before_filter CASClient::Frameworks::Rails::Filter, :if => Proc.new{|s| s.using_CAS?}
  def new
    @user_session = UserSession.new
  end

  def create
    @user_session = UserSession.new(params[:user_session])
    if @user_session.save
      flash[:notice] = "Successfully logged in."
      redirect_to root_url
    else
      render :action => 'new'
    end
  end

  def destroy
    @user_session = UserSession.find
    @user_session.destroy
    flash[:notice] = "Successfully logged out"
    redirect_to login_path
  end
end
