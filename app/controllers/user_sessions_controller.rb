class UserSessionsController < ApplicationController
  skip_before_filter :login_check
  skip_before_filter RubyCAS::Filter, :if => Proc.new{|s| s.using_CAS?}

  def new
    flash[:notice] = "Please login."
    @user_session = UserSession.new
  end

  def create
    @user_session = UserSession.new(params[:user_session])
    @user = User.where(:login == params[:user_session][:login]).first
    if @user && @user.auth_type!='built-in'
      flash[:notice] = "You are not supposed to be using built in authentication. Please click the relevant link below to log in using CAS."
      render :action => 'new'
    elsif @user_session.save
      flash[:notice] = "Successfully logged in."
      redirect_to root_url
    else
      render :action => 'new'
    end
  end

  def destroy
    @user_session = UserSession.find
    @user_session.destroy
    flash[:notice] = "Successfully logged out."
    redirect_to login_path
  end

  #Not called yet. Should be used once we migrate from using sessions_controller for CAS logout
  def cas_logout
    RubyCAS::Filter.logout(self)
  end

end
