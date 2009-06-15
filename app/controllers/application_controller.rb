# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  # almost everything we do is restricted to a department so we always load_department
  # feel free to skip_before_filter when desired
  before_filter :load_department
  before_filter CASClient::Frameworks::Rails::Filter

  helper :layout # include all helpers, all the time
  helper_method :current_user
  helper_method :current_department

  protect_from_forgery # See ActionController::RequestForgeryProtection for details

  def access_denied
    text = "Access denied"
    text += "<br>Maybe you want to go <a href=\"#{department_path(current_user.departments.first)}/shifts\">here</a>?" if current_user
    render :text => text, :layout => true
  end

  # Scrub sensitive parameters from your log
  # filter_parameter_logging :password

  protected
  # NOTE: opensource rails developers are more familiar with current_user than @user and it's clearer
  def current_user
    @current_user ||=
      User.find_by_login(session[:cas_user]) ||
      User.import_from_ldap(session[:cas_user], true)
  end

  # for department, current_department is a bit too long =),
  # one can use @department or current_department
  # current_department is suitable to those methods that skip_before_filter load_department
  def current_department
    @department ||= Department.find_by_id(params[:department_id] || session[:department_id])
  end

  private
  def load_department
    # update department id in session if neccessary so that we can use shallow routes properly
    session[:department_id] = params[:department_id] unless params[:department_id].blank?
    # load @department variable, no need ||= because it's only called once at the start of controller
    @department = Department.find_by_id(session[:department_id])
  end

  protected
  # these are the authorization before_filters to use under controllers
  def require_department_admin
    redirect_to(access_denied_path) unless current_user.is_admin_of?(@department)
  end
  def require_superuser
    unless current_user.is_superuser?
      flash[:notice] = "Only superuser can manage departments."
      redirect_to(access_denied_path)
    end
  end
end

