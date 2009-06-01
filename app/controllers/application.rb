# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  # almost everything we do is restricted to a department so we always load_department
  # feel free to skip_before_filter when desired
  before_filter :load_department

  helper_method :current_user

  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery # :secret => 'ac2a5d70e82f4f955e299a9b53a795ed'

  def access_denied
    render :text => "Access denied"
  end

  # See ActionController::Base for details
  # Uncomment this to filter the contents of submitted sensitive data parameters
  # from your application log (in this case, all fields with names like "password").
  # filter_parameter_logging :password

  protected
  def current_user
    session[:cas_user] = 'njg24'
    @current_user ||= User.find_by_netid(session[:cas_user]) || User.import_from_ldap(session[:cas_user], true)
  end

  # an alternative, for those methods that skip load_department before_filter
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

end

