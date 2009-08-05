class CalendarsController < ApplicationController
  layout 'calendar'
  
  def index
    @calendars = @department.calendars
    
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
    @visible_loc_groups = current_user.user_config.view_loc_groups.split(', ').map{|lg|LocGroup.find(lg)}
    @selected_loc_groups = @visible_loc_groups.collect{|l| l.id}
    @visible_locations = current_user.user_config.view_loc_groups.split(', ').map{|lg|LocGroup.find(lg)}.collect{|l| l.locations}.flatten.uniq
    
    @shifts = []
    @time_slots = []
    @calendars.each do |calendar|
      @shifts += calendar.shifts.in_locations(@visible_locations).on_days(@period_start, @period_start+6).scheduled
      #@shifts.store(calendar, calendar.shifts.in_locations(@visible_locations).on_days(@period_start, @period_start+6).scheduled.group_by{|t| t.start.strftime("%Y-%m-%d")})
      #@time_slots.store(calendar, calendar.time_slots.in_locations(@visible_locations).on_days(@period_start, @period_start+6).group_by{|t| t.start.strftime("%Y-%m-%d")})
      @time_slots += calendar.time_slots.in_locations(@visible_locations).on_days(@period_start, @period_start+6)
    end 
    @shifts = @shifts.group_by{|s| s.start.strftime("%Y-%m-%d")}
    @time_slots = @time_slots.group_by{|t| t.start.strftime("%Y-%m-%d")}
    
    
    @dept_start_hour = current_department.department_config.schedule_start / 60
    @dept_end_hour = current_department.department_config.schedule_end / 60
    @hours_per_day = (@dept_end_hour - @dept_start_hour)
    @time_increment = current_department.department_config.time_increment
    @blocks_per_hour = 60/@time_increment.to_f
  end
  
  def show
    @calendar = Calendar.find(params[:id])
    
    @period_start = params[:date] ? Date.parse(params[:date]).previous_sunday : Date.today.previous_sunday
    @visible_locations = current_user.user_config.view_loc_groups.split(', ').map{|lg|LocGroup.find(lg)}.collect{|l| l.locations}.flatten.uniq
    @shifts = @calendar.shifts.in_locations(@visible_locations).on_days(@period_start, @period_start+6).scheduled
    @time_slots = @calendar.time_slots.in_locations(@visible_locations).on_days(@period_start, @period_start+6)
  end
  
  def new
    @calendar = Calendar.new
  end
  
  def create
    @calendar = Calendar.new(params[:calendar])
    @calendar.department = @department
    if @calendar.save
      flash[:notice] = "Successfully created calendar."
      redirect_to @calendar
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
  
  def destroy
    @calendar = Calendar.find(params[:id])
    @calendar.destroy
    flash[:notice] = "Successfully destroyed calendar."
    redirect_to calendars_url
  end
end
