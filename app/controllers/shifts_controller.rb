class ShiftsController < ApplicationController

    helper :shifts


#Currently broken if there are no locations in the department
  def index
    @period_start = params[:date].blank? ? Date.parse("last Sunday") : Date.parse(params[:date])

    # for lists of shifts
    unless current_department.locations.empty?
      @active_shifts = Shift.all.select{|s| s.report and !s.submitted? and current_department.locations.include?(s.location)}.sort_by(&:start)
      @upcoming_shifts = current_user.shifts.select{|shift| !(shift.submitted?) and shift.scheduled? and shift.end > Time.now and @department.locations.include?(shift.location)}.sort_by(&:start)[0..3]
    else
      @active_shifts = @upcoming_shifts = []
    end
    @subs_you_requested = SubRequest.all.select{|sub| sub.shift.user == current_user}.sort_by(&:start)
    @subs_you_can_take = current_user.available_sub_requests

    # for user view preferences partial
    @loc_group_select = {}
    current_user.departments.each do |dept|
      @loc_group_select.store(dept.id, current_user.loc_groups(dept))
    end
    @selected_loc_groups = current_user.user_config.view_loc_groups.split(', ').map{|lg|LocGroup.find(lg).id}

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



    @time_slots = TimeSlot.all
    @period_start = params[:date] ? Date.parse(params[:date]).previous_sunday : Date.today.previous_sunday

    #TODO:simplify this stuff:
    @dept_start_hour = current_department.department_config.schedule_start / 60
    @dept_end_hour = current_department.department_config.schedule_end / 60
    @hours_per_day = (@dept_end_hour - @dept_start_hour)
    @dept_start_minute = @dept_start_hour * 60
    @dept_end_minute = @dept_end_hour * 60
    @block_length = 15
    @blocks_per_hour = 60/@block_length
    @blocks_per_day = @hours_per_day * @blocks_per_hour

    @loc_groups = current_user.user_config.view_loc_groups.split(', ').map{|lg|LocGroup.find(lg)}.select{|l| !l.locations.empty?}

    @table_height = @loc_groups.map{|l| l.locations }.flatten.uniq.length + @loc_groups.length * 0.25 + 1

  end

# Necessary? -ben
#  def show
#    @shift = Shift.find(params[:id])
#    return unless require_department_membership(@shift.department)
#  end

  def show_active
    @current_shifts = Shift.all.select{|s| s.report and !s.submitted? and @department.locations.include?(s.location)}.sort_by(&:start)
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
    (render :partial => 'shifts/tooltips/new', :layout => 'none') if params[:tooltip]
  end

  def unscheduled
    @shift = Shift.new
    respond_to do |format|
      format.html
      format.js
    end
  end

  def power_sign_up
    @shift = Shift.new
  end

  def create
    @shift = Shift.new(params[:shift])
    return unless require_department_membership(@shift.department)
    @shift.start = Time.now unless @shift.start
    unless current_user.is_admin_of?(@department) && @shift.scheduled?
      @shift.power_signed_up = false
      @shift.user = current_user
    end
    if @shift.save
      if !@shift.scheduled
        @report = Report.new(:shift => @shift, :arrived => Time.now)
        # add a report item about logging in
        @report.report_items << ReportItem.new(:time => Time.now, :content => current_user.login+" logged in at "+request.remote_ip, :ip_address => request.remote_ip)
        redirect_to @report and return if @report.save
      end
      respond_to do |format|
        format.html{ flash[:notice] = "Successfully created shift."; redirect_to(shifts_path)}
        format.js
      end
    else
      @shift.power_signed_up ? (render :action => 'power_sign_up') : (render :action => 'new')
    end
  end

  def edit
    @shift = Shift.find(params[:id])
    return unless require_owner_or_dept_admin(@shift, @shift.department)
    (render :partial => 'shifts/tooltips/edit', :layout => 'none') if params[:tooltip]
  end

  def update
    @shift = Shift.find(params[:id])
    return unless require_owner_or_dept_admin(@shift, @shift.department)
    if @shift.update_attributes(params[:shift])
      #combine with any compatible shifts
      respond_to do |format|
        format.html { flash[:notice] = "Successfully updated shift."; redirect_to @shift }
        format.js
      end
    else
      render :action => 'edit'
    end
  end

#unnecessary -ben
#yes necessary! see: canceling a shift, etc. -ryan
#okay then -ben
  def destroy
    @shift = Shift.find(params[:id])
    return unless require_owner(@shift)
    @shift.destroy
    flash[:notice] = "Successfully destroyed shift."
    redirect_to shifts_url
  end
end

