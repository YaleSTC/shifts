class CalendarsController < ApplicationController
  def index
    @calendars = @department.calendars
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
