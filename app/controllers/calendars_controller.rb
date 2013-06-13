class CalendarsController < ApplicationController
  layout 'calendar'
  before_filter :require_department_admin, :only => [:new, :create, :edit, :update, :destroy]

  def index
    @calendars = (current_user.is_admin_of?(@department) ? @department.calendars : @department.calendars.public)
    index_prep
  end

  def show
    @calendar = Calendar.find(params[:id])
    unless current_user.is_admin_of?(@department) or @calendar.public?
      flash[:notice] = "Only an administrator may view a private calendar."
      redirect_to shifts_path
      return
    end
    @calendars = [@calendar]
    index_prep
    render :action => 'index'
  end

  def new
    @calendar = Calendar.new
  end

  def create
    @calendar = Calendar.new(params[:calendar])
    @calendar.department = @department
    if @calendar.save
      flash[:notice] = "Successfully created calendar."
      redirect_to calendars_path
    else
      render :action => 'new'
    end
  end

  def edit
    @calendar = Calendar.find(params[:id])
  end

  def update
    @calendar = Calendar.find(params[:id])
    if @calendar.update_attributes(params[:calendar])
      flash[:notice] = "Successfully updated calendar."
      redirect_to @calendar
    else
      render :action => 'edit'
    end
  end

  def prepare_copy
    @calendar = Calendar.find(params[:id]).clone
  end

  def copy
    @old_calendar = Calendar.find(params[:id])
    @new_calendar = Calendar.new(params[:calendar])
    @new_calendar.department = @department
    wipe = params[:wipe] ? true : false
    begin
      ActiveRecord::Base.transaction do
        if @new_calendar.save!
          errors = Calendar.copy(@old_calendar, @new_calendar, wipe)
        end
        raise errors.to_s unless !errors || errors.empty?
        redirect_to calendars_path
      end
    rescue Exception => e
      @errors = e.message.gsub("Validation failed:", "").split(",")
      @calendar = @new_calendar.clone
      render :action => 'prepare_copy'
    end
  end

  def destroy
    @calendar = Calendar.find(params[:id])
    ActiveRecord::Base.transaction do
      Calendar.destroy_self_and_future(@calendar)
    end
    flash[:notice] = "Successfully destroyed calendar."
    redirect_to calendars_url
  end


#just a view -mike

  def prepare_wipe_range
  end

  def wipe_range
    @calendar = Calendar.new(params[:start_and_end])
    @start = @calendar.start_date
    @end = @calendar.end_date
    Calendar.wipe_range(@start, @end, params[:time_slots], params[:shifts], params[:location_ids], params[:cal_ids])
    flash[:notice] = "Successfully wiped range of days."
    redirect_to calendars_path
  end

#just a view -mike
  def warn
  end

  def toggle
    @calendar = Calendar.find(params[:id])
    if params[:wipe]
      wipe = true
    else
      wipe =false
    end
    ActiveRecord::Base.transaction do
      if @calendar.active
          @calendar.deactivate
          @problems = false
      else
          @problems = @calendar.activate(wipe)
      end
    end
    if @problems
      @problems = @problems.split(",")
      render :action => "warn"
    else
      flash[:notice] = "The calendar was successfully #{@calendar.active ? 'activated' : 'deactivated'}"
      redirect_to :action => "index"
    end
  end
  
  
  def apply_schedule
    @calendar = Calendar.find(params[:id])
    ActiveRecord::Base.transaction do
      (@calendar.time_slots + @calendar.shifts).each do |event|
        RepeatingEvent.create_from_existing_event(event)
      end
    end
    flash[:notice] = "Schedule applied successfully."
    redirect_to @calendar
  end
  

  private
  def index_prep
    @period_start = params[:date] ? Date.parse(params[:date]).previous_sunday : Date.today.previous_sunday
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

    @loc_group_select = {}
    @loc_group_select[@department.id] = @department.loc_groups #{}
    @visible_loc_groups = current_user.user_config.view_loc_groups
    @selected_loc_groups = @visible_loc_groups.collect{|l| l.id}
    @visible_locations = current_user.user_config.view_loc_groups.collect{|l| l.locations}.flatten.select{|l| l.active?}

    @dept_start_hour = current_department.department_config.schedule_start / 60
    @dept_end_hour = current_department.department_config.schedule_end / 60
    @hours_per_day = (@dept_end_hour - @dept_start_hour)
    @time_increment = current_department.department_config.time_increment
    @blocks_per_hour = 60/@time_increment.to_f

    #get calendar colors
    @color_array = ["9f9", "9ff", "ff9", "f9f", "f99", "99f"]
    @color = {}
    @calendars.each_with_index{ |calendar, i| @color[calendar] ||= @color_array[i%6]}
  end
end
