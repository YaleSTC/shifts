class FirstRunController < ApplicationController
  before_filter :redirect_if_not_first_run
  skip_before_filter :login_check
  skip_before_filter :load_user


  def new_app_config
    @app_config = AppConfig.first || AppConfig.new
  end

  def create_app_config
    AppConfig.first.destroy if AppConfig.first
    @app_config=AppConfig.new(params[:app_config])
    @app_config.calendar_feed_hash = ActiveSupport::SecureRandom.hex(32) #must be 32 characters
    @app_config.use_ldap = params[:app_config][:use_ldap] && params[:app_config][:use_ldap] == "1" ? true : false
    if @app_config.save
      flash[:notice] = "App Settings have been configured."
      redirect_to first_department_path
    else
      render action: 'new_app_config'
    end
  end

  def new_department
    @department = Department.first || Department.new
  end

  def create_department
    Department.destroy_all if Department.all.any?
    @department=Department.new(params[:department])
    if @department.save
      flash[:notice] = "The first department was successfully created."
      redirect_to first_user_path
    else
      render action: 'new_department'
    end
  end

  def new_user
    @user = User.new
    @results=[]
  end

  def create_user
    @user = User.new(params[:user])
    @user.auth_type = @appconfig.login_options[0] if @appconfig.login_options.size == 1
    @user.departments << Department.first
    @user.superuser = true
    @user.set_random_password if @user.auth_type=='CAS'
    if @user.save
      flash[:notice] = "Successfully set up application."
      redirect_to @user
    else
      render action: 'new_user'
    end
  end

  def ldap_search
    @results=User.search_ldap(params[:user][:first_name],params[:user][:last_name],params[:user][:email],5)
  end

  def fill_form
    @user=User.new(params[:user])
  end

private
  def redirect_if_not_first_run
    if User.all.any?
      flash[:error] = "The setup wizard can only be run on first launch."
      redirect_to access_denied_path
    end
  end

end
