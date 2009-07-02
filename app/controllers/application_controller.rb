# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  # almost everything we do is restricted to a department so we always load_department
  # feel free to skip_before_filter when desired
#  before_filter :test
  before_filter :load_user_session
  before_filter CASClient::Frameworks::Rails::Filter, :if => Proc.new{|s| s.using_CAS? && LOGIN_OPTIONS.include?('CAS')}, :except => 'access_denied'
  before_filter :login_check, :except => :access_denied
  before_filter :load_department
#  before_filter :load_user

  helper :layout # include all helpers, all the time
  helper_method :current_user
  helper_method :current_department
  
  filter_parameter_logging :password, :password_confirmation

  protect_from_forgery # See ActionController::RequestForgeryProtection for details
  
  APP_CONFIG = AppConfig.first

  def access_denied
    text = "Access denied"
     text += "<br>Maybe you want to <a href=\"#{login_path}\">try logging in with built-in authentication</a>?" if LOGIN_OPTIONS.include?('authlogic')
    text += "<br>Maybe you want to go <a href=\"#{department_path(current_user.departments.first)}/users\">here</a>?" if current_user && current_user.departments
    render :text => text, :layout => true
  end

  def using_CAS?
    !current_user || current_user.auth_type=='CAS'
  end

  protected
  # NOTE: opensource rails developers are more familiar with current_user than @user and it's clearer
  def current_user
#    raise @user_session.login.to_s
    if @user_session
      @user_session.user
    elsif session[:cas_user]
      User.find_by_login(session[:cas_user])
    else
      nil
    end
  end

  # for department, current_department is a bit too long =),
  # one can use @department or current_department
  # current_department is suitable to those methods that skip_before_filter load_department
  def current_department
    if params[:department_id] or session[:department_id]
        @department ||= Department.find(params[:department_id] || session[:department_id])
    elsif current_user and current_user.departments
      @department = current_user.user_config.default_dept ? Department.find(current_user.user_config.default_dept) : current_user.departments[0]
    elsif current_user and current_user.is_superuser?
      @department = Department.first
    end
  end

  # Application-wide settings are stored in the only record in the app_configs table
#  def app_config
#    AppConfig.first
#  end

  private
  def load_department
    # update department id in session if neccessary so that we can use shallow routes properly
      if params[:department_id]
        session[:department_id] = params[:department_id]
        @department = Department.find_by_id(session[:department_id])
      elsif session[:department_id]
        @department = Department.find_by_id(session[:department_id])
      elsif current_user and current_user.departments
        @department = current_user.departments[0]
      end
   # load @department variable, no need ||= because it's only called once at the start of controller
  end

  def load_user
    @current_user = @user_session.user || User.find_by_login(session[:cas_user]) || User.import_from_ldap(session[:cas_user], true)
  end

  def load_user_session
    @user_session = UserSession.find
  end

  # these are the authorization before_filters to use under controllers
  def require_department_admin
    redirect_to(access_denied_path) unless current_user.is_admin_of?(@department)
  end

  def require_loc_group_admin
    redirect_to(access_denied_path) unless current_user.is_admin_of?(@loc_group)
  end

  def require_superuser
    unless current_user.is_superuser?
      flash[:notice] = "Only superuser can manage departments."
      redirect_to(access_denied_path)
    end
  end

  def login_check
    unless current_user
      if LOGIN_OPTIONS==['authlogic'] #AppConfig.first.login_options_array.include?('authlogic')
        redirect_to login_path
      else
        redirect_to access_denied_path
      end
    end
  end

  def redirect_with_flash(msg = nil, options = {:action => :index})
    if msg
      msg = msg.join("<br/>") if msg.is_a?(Array)
      flash[:notice] = msg
    end
    redirect_to options
  end

  def test
    raise "ewoks"
  end

end
