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
    begin
      @shift = Shift.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      respond_to do |format|
        format.html #freak out
        format.js do
          render :update do |page|
            ajax_alert(page, "<strong>Error (404):</strong> shift ##{params[:id]} cannot be found. Please refresh the current page.")
            page.hide "tooltip"
          end
        end
      end
    else
      return unless require_department_membership(@shift.department)
    end
  end

  def show_active
    @signed_in_shifts = Shift.signed_in(current_department).group_by(&:loc_group).sort_by(&:id)
  end

  def show_unscheduled
    @start_date = 1.week.ago
    @end_date = Date.current
    if request.post?
      @start_date = Time.local(params[:start][:year], params[:start][:month], params[:start][:day])
      @end_date = Time.local(params[:end][:year], params[:end][:month], params[:end][:day], 23, 59, 59)
    end
    @unscheduled_shifts_by_locgroup = Shift.unscheduled.in_department(current_department).on_days(@start_date, @end_date).sort_by(&:start).group_by(&:loc_group)
  end

  def new
    params[:shift][:end] ||= params[:shift][:start] if params[:shift] and params[:shift][:start]
    @shift = Shift.new(params[:shift])
    calculate_default_times
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

# needed when simple_time_select is implemented
    parse_date_and_time_output(params[:shift])

    @shift = Shift.new(params[:shift])
    @shift.department = @shift.location.department
    return unless require_department_membership(@shift.department)
    @shift.start = Time.now unless @shift.start
    @shift.calendar = @department.calendars.default unless @shift.calendar
    unless current_user.is_admin_of?(@department) && @shift.scheduled?
      @shift.power_signed_up = false
      @shift.user = current_user
    end
    if !@shift.scheduled && (current_user.current_shift || current_user.punch_clock)
      flash[:notice] = "You can't sign into two shifts or punch clocks at the same time."
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
        if @report.save
          @report.report_items << ReportItem.new(:time => Time.now, :content => current_user.login+" logged in at "+request.remote_ip, :ip_address => request.remote_ip)
          redirect_to @report and return
        end
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

    @range_start_time = "a"
    @range_end_time = "a"
    @default_start = "a"
    @default_end = "a"

#    calculate_default_times
    return unless user_is_owner_or_admin_of(@shift, @shift.department)
    (render :partial => 'shifts/tooltips/edit', :layout => 'none') if params[:tooltip]
  end

  def update

#    needed when simple_time_select is implemented
    parse_date_and_time_output(params[:shift])

    @shift = Shift.find(params[:id])
    return unless user_is_owner_or_admin_of(@shift, @shift.department)
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

#calculates default_start/end and range_start/end_time
    def calculate_default_times
      if params[:id]
        @default_start = @shift.start
        @default_end = @shift.end
      elsif params[:xPercentage]
        @default_start = (params[:date] ? Time.parse(params[:date]) : Time.now).to_date
        @dept_start_minutes ||= current_department.department_config.schedule_start
        @dept_end_minutes ||= current_department.department_config.schedule_end
        @minutes_per_day ||= (@dept_end_minutes - @dept_start_minutes)
        @default_start += @dept_start_minutes.minutes
        @default_start += (@minutes_per_day * params[:xPercentage].to_f / 60).to_int * 3600 #truncates the hour
#if the time slot starts off of the hour (at 9:30), this is not ideal because it will select either 9:00 or 10:00 and the following hour. We need timeslot validation first.
#if the schedule starts at 9:30, I'm not sure what happens ~Casey
        @default_end = @default_start + 1.hour
      else
        @default_start = (params[:date] ? Time.parse(params[:date]) : Time.now).to_date.to_time + current_department.department_config.schedule_start.minutes
        @default_end = @default_start + 1.hour
      end

      @range_start_time = Time.now.to_date + current_department.department_config.schedule_start.minutes
      @range_end_time = Time.now.to_date + current_department.department_config.schedule_end.minutes

    end


end

