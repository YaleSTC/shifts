class TimeSlotsController < ApplicationController
  before_filter :require_department_admin
  layout 'shifts'

  def index
    @time_slots = TimeSlot.all
    @period_start = params[:date].blank? ? Date.parse("last Sunday") : Date.parse(params[:date])
  end

  def show
    @time_slot = TimeSlot.find(params[:id])
  end

  def new
    @time_slot = TimeSlot.new
  end

  def create
    errors = []
    for location_id in params[:location_ids]
      for day in params[:days]
        week = Date.today.beginning_of_week - 1 #go back to sunday
        time_slot = TimeSlot.new(params[:time_slot])
        time_slot.location_id = location_id
        time_slot.start = week + day.to_i + time_slot.start.seconds_since_midnight
        time_slot.end = week + day.to_i + time_slot.end.seconds_since_midnight
        if !time_slot.save
          errors << "Error saving timeslot for #{WEEK_DAYS[day]}"
        end
      end
    end
    if errors.empty?
      flash[:notice] = "Successfully created timeslot(s)."
      redirect_to time_slots_path
    else
      flash[:error] =  "Error: "+errors*"<br/>" 
    end
  end

  def edit
    @time_slot = TimeSlot.find(params[:id])
  end

  def update
    @time_slot = TimeSlot.find(params[:id])
    if @time_slot.update_attributes(params[:time_slot])
      flash[:notice] = "Successfully updated timeslot."
      redirect_to @time_slot
    else
      render :action => 'edit'
    end
  end

  def destroy
    @time_slot = TimeSlot.find(params[:id])
    @time_slot.destroy
    flash[:notice] = "Successfully destroyed timeslot."
    redirect_to time_slots_url
  end
end

