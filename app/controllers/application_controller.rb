# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  # almost everything we do is restricted to a department so we always load_department
  # feel free to skip_before_filter when desired
  before_filter :load_app_config
  before_filter :department_chooser
  before_filter :load_user_session
  before_filter CASClient::Frameworks::Rails::Filter, :if => Proc.new{|s| s.using_CAS?}, :except => 'access_denied'
  before_filter :login_check, :except => :access_denied
  before_filter :load_department
  before_filter :prepare_mail_url
  #before_filter :load_user


  helper :layout # include all helpers, all the time (whyy? -Nathan)
  helper_method :current_user
  helper_method :current_department

  filter_parameter_logging :password, :password_confirmation

  protect_from_forgery # See ActionController::RequestForgeryProtection for details

  layout :detect_browser

  def load_app_config
    @appconfig = AppConfig.first
  end

  def access_denied
    render :file => "layouts/access_denied.html.erb", :layout => true
  end

  def using_CAS?
    User.first && (!current_user || current_user.auth_type=='CAS') && @appconfig && @appconfig.login_options.include?('CAS')
  end

  protected
  def current_user
    @current_user ||= (
    if @user_session
      @user_session.user
    elsif session[:cas_user]
      User.find_by_login(session[:cas_user])
    else
      nil
    end)
  end

  def current_department
    unless @current_department
      if current_user
        @current_department = Department.find_by_id(session[:department_id])
        unless @current_department
          @current_department = current_user.default_department
          session[:department_id] = @current_department.id
        end
      end
    end
    @current_department
  end

  def load_department
    if (params[:department_id])
      @department = Department.find_by_id(params[:department_id])
      if @department
        session[:department_id] = params[:department_id]
      end
    end
    @department ||= current_department
  end

  def load_user
    @current_user = @user_session.user || User.find_by_login(session[:cas_user]) || User.import_from_ldap(session[:cas_user], true)
  end

  def load_user_session
    @user_session = UserSession.find
  end

  # These are the authorization before_filters to use under controllers
  # These all return nil
  def require_department_admin
    unless current_user.is_admin_of?(current_department)
      error_message = "That action is restricted to department administrators."
      respond_to do |format|
        format.html do
          flash[:error] = error_message
          redirect_to access_denied_path
        end
        format.js do
          render :update do |page|
            # display alert
            ajax_alert(page, "<strong>error:</strong> "+error_message);
          end
          return false
        end
      end
    end
    return true
  end

  def require_loc_group_admin(current_loc_group)
    unless current_user.is_admin_of?(current_loc_group)
      error_message = "That action is restricted to location group administrators."
      respond_to do |format|
        format.html do
          flash[:error] = error_message
          redirect_to access_denied_path
        end
        format.js do
          render :update do |page|
            # display alert
            ajax_alert(page, "<strong>error:</strong> "+error_message);
          end
          return false
        end
      end
    end
    return true
  end

	def require_any_loc_group_admin
    unless current_user.is_loc_group_admin?(current_department)
      error_message = "That action is restricted to location group administrators."
      respond_to do |format|
        format.html do
          flash[:error] = error_message
          redirect_to access_denied_path
        end
        format.js do
          render :update do |page|
            # display alert
            ajax_alert(page, "<strong>error:</strong> "+error_message);
          end
          return false
        end
      end
    end
    return true
  end

  def require_superuser
    unless current_user.is_superuser?
      error_message = "That action is only available to superusers."
      respond_to do |format|
        format.html do
          flash[:error] = error_message
          redirect_to access_denied_path
        end
        format.js do
          render :update do |page|
            # display alert
            ajax_alert(page, "<strong>error:</strong> "+error_message);
          end
          return false
        end
      end
    end
    return true
  end

  def require_proper_template_role
    unless current_user.has_proper_role_for?(Template.find(params[:template_id])) || current_user.is_admin_of?(Template.find(params[:template_id]).department)
      error_message = "This page is only availabe to the following roles: #{Template.find(params[:template_id]).roles.to_sentence}"
      flash[:error] = error_message
      redirect_to access_denied_path
    end
    return true
  end

  # These three methods all return true/false, so they can be tested to
  # trigger return statements

  # TODO: Ultimately, we should abstract all this away into a permissions
  # module, and include that into the application. Ideally, after that we'd
  # refactor to to have these methods share the redirect code

  # Takes a department, location, or loc_group
  def user_is_admin_of(thing)
    unless current_user.is_admin_of?(thing)
      error_message = "You are not authorized to administer this #{thing.class.name.decamelize}."
      respond_to do |format|
        format.html do
          flash[:error] = error_message
          redirect_to access_denied_path and return false
        end
        format.js do
          render :update do |page|
            # display alert
            ajax_alert(page, "<strong>error:</strong> "+error_message);
          end
          return false
        end
      end
    end
    return true
  end


  # Takes any object that has a user method and checks against current_user
  #TODO: This is mixing model logic!!!
  def user_is_owner_of(thing)
    unless current_user.is_owner_of?(thing)
      error_message = "You are not the owner of this #{thing.class.name.decamelize}."
      respond_to do |format|
        format.html do
          flash[:error] = error_message
          redirect_to access_denied_path and return false
        end
        format.js do
          render :update do |page|
            # display alert
            ajax_alert(page, "<strong>error:</strong> "+error_message);
          end
          return false
        end
      end
    end
    return true
  end

  # Takes any object that has a user method and its department
  #TODO: This is mixing model logic!!!
  def user_is_owner_or_admin_of(thing, dept)
    unless current_user.is_owner_of?(thing) || current_user.is_admin_of?(dept)
      error_message = "You are not the owner of this #{thing.class.name.decamelize}, nor are you the department administrator."
      respond_to do |format|
        format.html do
          flash[:error] = error_message
          redirect_to access_denied_path and return false
        end
        format.js do
          render :update do |page|
            # display alert
            ajax_alert(page, "<strong>error:</strong> "+error_message);
          end
          return false
        end
      end
    end
    return true
  end

  # Takes a department; intended to be passed some_thing.department
  def require_department_membership(dept)
    unless current_user.departments.include?(dept)
      error_message = "You are not a member of the appropriate department."
      respond_to do |format|
        format.html do
          flash[:error] = error_message
          redirect_to access_denied_path and return false
        end
        format.js do
          render :update do |page|
            ajax_alert(page, "<strong>error:</strong> "+error_message);
          end
          return false
        end
      end
    end
    return true
  end

  def login_check
    if !User.first
      redirect_to first_app_config_path
    elsif !current_user
      if @appconfig.login_options==['built-in'] #AppConfig.first.login_options_array.include?('built-in')
        redirect_to login_path
      else
        redirect_to access_denied_path
      end
    end
  end

#  def redirect_with_flash(msg = nil, options = {:action => :index})
#    if msg
#      msg = msg.join("<br/>") if msg.is_a?(Array)
#      flash[:notice] = msg
#    end
#    redirect_to options
#  end

  def parse_date_and_time_output(form_output)
		time_attribute_names = ["start", "end", "mandatory_start", "mandatory_end"]
    time_attribute_names.each do |field_name|
      ## Simple Time Select Input
      if !form_output["#{field_name}_time(5i)"].blank? && form_output["#{field_name}_time(4i)"].blank?
        form_output["#{field_name}_time"] = Time.parse( form_output["#{field_name}_time(5i)"] )
      end

      ## Date Input - Hidden Field
      unless form_output["#{field_name}_date"].blank?
        form_output["#{field_name}_date"] = Date.parse( form_output["#{field_name}_date"] )
      end

      ## Date Input - Select (Rails default)
      unless (form_output["#{field_name}_date(1i)"].blank? || form_output["#{field_name}_date(2i)"].blank? || form_output["#{field_name}_date(3i)"].blank?)
        join_date = [ form_output["#{field_name}_date(1i)"], form_output["#{field_name}_date(2i)"], form_output["#{field_name}_date(3i)"] ].join('-')
        form_output["#{field_name}_date"] = Date.parse( join_date )
      end
    end


    #when there is no end_date (such as shifts, time_slots, and sub_requests)
    form_output["end_date"] ||= form_output["start_date"] if form_output["start_date"]
    form_output["mandatory_end_date"] ||= form_output["mandatory_start_date"] if form_output["mandatory_start_date"]

    #Midnight?
    time_attribute_names.each do |field_name|
        unless form_output["#{field_name}_time(5i)"].nil?
          unless form_output["#{field_name}_time(5i)"].scan(/\+$/).empty?
            form_output["#{field_name}_date"] += 1.day
          end
        end
    end

    #cleanup
    time_attribute_names.each do |field_name|
        form_output.delete("#{field_name}_date(1i)")
        form_output.delete("#{field_name}_date(2i)")
        form_output.delete("#{field_name}_date(3i)")
        form_output.delete("#{field_name}_time(5i)") if form_output["#{field_name}_time(4i)"].blank?
    end

    form_output
  end

  def set_payform_item_hours(model_name)
    if params[:calculate_hours] == 'user_input'
      params[model_name.to_sym][:hours] = params[:other][:hours].to_f + params[:other][:minutes].to_f/60
    else
      start_params = []
      end_params = []
      for num in (1..7)
        unless num == 6 #we skip seconds; meridian is stored in 7
          start_params << params[:time_input]["start(#{num}i)"].to_i
          end_params << params[:time_input]["end(#{num}i)"].to_i
        end
      end
      start_time = convert_to_time(start_params)
      end_time = convert_to_time(end_params)
      params[model_name.to_sym][:hours] = (end_time-start_time) / 3600.0
    end
  end

  def convert_to_time(date_array)
    # 0 = year, 1 = month, 2 = day, 3 = hour, 4 = minute, 5 = meridiem(am/pm)
    if date_array[3] == 12 #if noon or midnight
      date_array[3] -= 12
    end
    if date_array[5] == -2 #if pm
      date_array[3] += 12
    end
    Time.utc(date_array[0], nil, nil, date_array[3], date_array[4])
  end


  def join_date_and_time(form_output)
  #join date and time
    %w{start end mandatory_start mandatory_end}.each do |field_name|
      if form_output["#{field_name}_date"] && form_output["#{field_name}_time"]
        form_output["#{field_name}"] ||= form_output["#{field_name}_date"].beginning_of_day + form_output["#{field_name}_time"].seconds_since_midnight
        form_output.delete("#{field_name}_date")
        form_output.delete("#{field_name}_time")
      end
      form_output["start"] ||= Time.now
      form_output
    end
  end

  private


  def department_chooser
    if (params[:su_mode] && current_user.superuser?)
      current_user.update_attribute(:supermode, params[:su_mode]=='ON')
      flash[:notice] = "Supermode is now #{current_user.supermode? ? 'ON' : 'OFF'}"
      redirect_to :action => "index" and return
    end
    if (params["chooser"] && params["chooser"]["dept_id"])
      session[:department_id] = params["chooser"]["dept_id"]
      redirect_to switch_department_path and return
    end
  end

  #checks to see if the action should be rendered without a layout. optionally pass it another action/controller
  def layout_check(action = action_name, controller = controller_name)
     if params[:layout] == "false"
      render :controller => controller, :action => action, :layout => false
    end
  end

  # overwrite this method in other controller if you wanna go to a different url after chooser submit
  # it tries to find the index path of the current resource;
  # for example if you're in shifts_controller then it goes to shifts_path
  # however it won't work for some nested routes (and defaults to root_path instead) so please overwrite this method in such controller
  def switch_department_path
    send("#{controller_name}_path") rescue root_path
  end

  def prepare_mail_url
    ActionMailer::Base.default_url_options[:host] = request.host_with_port
  end


end
