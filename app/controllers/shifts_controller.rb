class ShiftsController < ApplicationController
  helper :shifts

  def index
    @period_start = params[:date] ? Date.parse(params[:date]).previous_sunday : Date.today.previous_sunday

    # for user view preferences partial
    @loc_group_select = {}
    current_user.departments.each do |dept|
      @loc_group_select.store(dept.id, current_user.loc_groups(dept))
    end

    # figure out what days to display based on user preferences
    if params[:date].blank? and (current_user.user_config.view_week != "" and current_user.user_config.view_week != "whole_period")
      # only if default view and non-standard setting
      if current_user.user_config.view_week == "current_day"
        @day_collection = [Date.today]
      elsif current_user.user_config.view_week == "remainder"
        if @department.department_config.weekend_shifts #show weekends
          @day_collection = Date.today...(@period_start+7)
        else
          @day_collection = Date.today...(@period_start+6)
        end
      end
    elsif @department.department_config.weekend_shifts #show weekends
      @day_collection = @period_start...(@period_start+7)
    else #no weekends
      @day_collection = (@period_start+1)...(@period_start+6)
    end

    @loc_groups = current_user.loc_groups(current_department)
    @visible_loc_groups = current_user.user_config.view_loc_groups
    @selected_loc_groups = @visible_loc_groups.collect{|l| l.id}
    @visible_locations = current_user.user_config.view_loc_groups.collect{|l| l.locations}.flatten

    # @calendars = @department.calendars.active
    # @shifts = []
    # @time_slots = []
    # @calendars.each do |calendar|
    #   @shifts += calendar.shifts.in_locations(@visible_locations).on_days(@period_start, @period_start+6).scheduled
    #   #@shifts.store(calendar, calendar.shifts.in_locations(@visible_locations).on_days(@period_start, @period_start+6).scheduled.group_by{|t| t.start.strftime("%Y-%m-%d")})
    #   #@time_slots.store(calendar, calendar.time_slots.in_locations(@visible_locations).on_days(@period_start, @period_start+6).group_by{|t| t.start.strftime("%Y-%m-%d")})
    #   @time_slots += calendar.time_slots.in_locations(@visible_locations).on_days(@period_start, @period_start+6)
    # end
    # @shifts = @shifts.group_by{|s| s.start.strftime("%Y-%m-%d")}
    # @time_slots = @time_slots.group_by{|t| t.start.strftime("%Y-%m-%d")}

    #@time_slots = TimeSlot.all


    #TODO:simplify this stuff:
    @dept_start_hour = current_department.department_config.schedule_start / 60
    @dept_end_hour = current_department.department_config.schedule_end / 60
    @hours_per_day = (@dept_end_hour - @dept_start_hour)
    @time_increment = current_department.department_config.time_increment
    @blocks_per_hour = 60/@time_increment.to_f


  end

# TODO: verify that it can be removed
# Necessary? -ben
# No, but since the shifts view is broken,i'm using this.
  def show
    @shift = Shift.find(params[:id])
    return unless require_department_membership(@shift.department)
  end

# TODO: write the view
# Temporarily deactivated because its view is unfinished, and will be slightly tricky design-wise -ben
  def show_active
    @current_shifts = Shift.in_locations(current_department.locations).signed_in.sort_by(&:start)
  end

  def show_unscheduled
    @start_date = 1.week.ago
    @end_date = Date.current
    if request.post?
      @start_date = Time.local(params[:start][:year], params[:start][:month], params[:start][:day])
      @end_date = Time.local(params[:end][:year], params[:end][:month], params[:end][:day], 23, 59, 59)
    end
    @unscheduled_shifts_by_locgroup = Shift.all.select{|s| !s.scheduled? and @department.locations.include?(s.location) and (@start_date <= s.start and s.start <= @end_date)}.sort_by(&:start).group_by(&:loc_group)
  end

  def new
    params[:shift][:end] ||= params[:shift][:start] if params[:shift] and params[:shift][:start]
    @shift = Shift.new(params[:shift])
    if params[:tooltip]
      @shift.user_id = current_user.id
      render :partial => 'shifts/tooltips/new', :layout => 'none'
    end
  end

  def unscheduled
    @shift = Shift.new
    respond_to do |format|
      format.html
      format.js
    end
  end

  def create
    @shift = Shift.new(params[:shift])
    @shift.department = @shift.location.department
    return unless require_department_membership(@shift.department)
    @shift.start = Time.now unless @shift.start
    @shift.calendar = @department.calendars.default unless @shift.calendar
    unless current_user.is_admin_of?(@department) && @shift.scheduled?
      @shift.power_signed_up = false
      @shift.user = current_user
    end
    if !@shift.scheduled && current_user.current_shift
      flash[:notice] = "You can't sign into two shifts!"
      redirect_to shifts_path and return
    elsif !@shift.power_signed_up && !current_user.can_signup?(@shift.location.loc_group)
      flash[:notice] = "You don't have permission to sign up for a shift there!"
      redirect_to shifts_path and return
    end
    if @shift.save
      if !@shift.scheduled
        @report = Report.new(:shift => @shift, :arrived => Time.now)
        @shift.signed_in = true
        @shift.save
        @report.report_items << ReportItem.new(:time => Time.now, :content => current_user.login+" logged in at "+request.remote_ip, :ip_address => request.remote_ip)
        redirect_to @report and return if @report.save
      end
      respond_to do |format|
        format.html{ flash[:notice] = "Successfully created shift."; redirect_to(shifts_path)}
        format.js
      end
    else
      respond_to do |format|
        format.html{ render :action => 'new' }
        format.js do
          render :update do |page|
            error_string = ""
            @shift.errors.each do |attr_name, message|
              error_string += "<br><br>#{attr_name}: #{message}"
            end
            ajax_alert(page, "<strong>Error:</strong> shift could not be saved"+error_string, 2.5 + (@shift.errors.size))
          end
        end
      end
    end
  end

  def edit
    @shift = Shift.find(params[:id])
    @report = @shift.report
    return unless require_owner_or_dept_admin(@shift, @shift.department)
    (render :partial => 'shifts/tooltips/edit', :layout => 'none') if params[:tooltip]
  end

  def update
    @shift = Shift.find(params[:id])
    return unless require_owner_or_dept_admin(@shift, @shift.department)
    if @shift.update_attributes(params[:shift])
      #combine with any compatible shifts
      respond_to do |format|
        format.js
        format.html do
          flash[:notice] = "Successfully updated shift."
          redirect_to @shift
        end
      end
    else
      respond_to do |format|
        format.js do
          render :update do |page|
            error_string = ""
            @shift.errors.each do |attr_name, message|
              error_string += "<br><br>#{attr_name}: #{message}"
            end
            ajax_alert(page, "<strong>error:</strong> updated shift could not be saved"+error_string, 2.5 + (@shift.errors.size))
          end
        end
        format.html {render :action => 'edit'}
      end
    end
  end

  def destroy
    @shift = Shift.find(params[:id])
    if current_user.is_admin_of?(current_department) or (@shift.user == current_user and @shift.calendar.public? and !@shift.calendar.active?)
      @shift.destroy
      respond_to do |format|
        format.html {flash[:notice] = "Successfully destroyed shift."; redirect_to shifts_url}
        format.js #remove partial from view
      end
    else
      respond_to do |format|
        format.html {flash[:notice] = "That action is restricted."; redirect_to access_denied_path}
        format.js do
          render :update do |page|
            # display alert
            ajax_alert(page, "<strong>error:</strong> That action is restricted.");
          end
        end
      end
    end
  end

  # def rerender
  #   #@period_start = params[:date] ? Date.parse(params[:date]) : Date.today.end_of_week-1.week
  #   #TODO:simplify this stuff:
  #   @dept_start_hour = current_department.department_config.schedule_start / 60
  #   @dept_end_hour = current_department.department_config.schedule_end / 60
  #   @hours_per_day = (@dept_end_hour - @dept_start_hour)
  #   #@block_length = current_department.department_config.time_increment
  #   #@blocks_per_hour = 60/@block_length.to_f
  #   #@blocks_per_day = @hours_per_day * @blocks_per_hour
  #   #@hidden_timeslots = [] #for timeslots that don't show up on the view
  #   @shift = Shift.find(params[:id])
  #   respond_to do |format|
  #     format.js
  #   end
  # end
end

