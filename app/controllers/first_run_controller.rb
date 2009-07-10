class FirstRunController < ApplicationController
  skip_before_filter :login_check, :if => Proc.new {User.first}
  before_filter :redirect_if_not_first_run
  def new_app_config
    @app_config = AppConfig.first || AppConfig.new
  end

  def create_app_config
    AppConfig.first.destroy if AppConfig.first
    @app_config=AppConfig.new(params[:app_config])
    if @app_config.save
      flash[:notice] = "App Settings have been configured."
      redirect_to first_department_path
    else
      render :action => 'new_app_config'
    end
  end

  def new_department
    @department = Department.first || Department.new
  end

  def create_department
    Department.first.destroy if Department.first
    @department=Department.new(params[:department])
    if @department.save
      flash[:notice] = "The first department was successfully created."
      redirect_to first_user_path
    else
      render :action => 'new_department'
    end
  end

  def new_user
    @user = User.new
  end

  def create_user
    @user = User.new(params[:user])
    @user.departments << Department.first
    @user.superuser = true
    @user.auth_type = $appconfig.login_options[0] if $appconfig.login_options.size == 1
    if @user.auth_type == "authlogic"
      if @user.save
        flash[:notice] = "Successfully created user and finished the initial startup."
        redirect_to root_path
      else
        render :action => 'new_user'
      end
    else
      #create from LDAP if possible; otherwise just use the given information
      @user = User.import_from_ldap(params[:user][:login]) || User.create(params[:user])
      @user.departments << Department.first
      #if a name was given, it should override the name from LDAP
      @user.first_name = (params[:user][:first_name]) unless params[:user][:first_name]==""
      @user.last_name = (params[:user][:last_name]) unless params[:user][:last_name]==""
      @user.roles = (params[:user][:role_ids] ? params[:user][:role_ids].collect{|id| Role.find(id)} : [])
      @user.password = @user.password_confirmation = random_password
      @user.auth_type='CAS'
      @user.superuser = true
        if @user.save
          flash[:notice] = "Successfully created user and finished the initial startup."
          if @user.auth_type=='authlogic'
            redirect_to login_path
          else
            redirect_to root_path
          end
        else
           render :action => 'new_user'
        end
#         y @user #debug output
    end
  end

private
  def redirect_if_not_first_run
    if User.first
      flash[:notice] = "The setup wizard can only be run on first launch."
      redirect_to access_denied_path
    end
  end

end
