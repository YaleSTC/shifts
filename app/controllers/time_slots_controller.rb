class TimeSlotsController < ApplicationController
  before_filter :require_department_admin
  layout 'shifts'

  def index
    @time_slots = TimeSlot.all
    @period_start = params[:date] ? Date.parse(params[:date])+1.day : Date.today
  end

  def show
    @time_slot = TimeSlot.find(params[:id])
  end

  def new
    @time_slot = TimeSlot.new
  end

  def create
    errors = []
    date = params[:date] ? Time.parse(params[:date]) : Time.now.beginning_of_week - 1.day
    for location_id in params[:location_ids]
      for day in params[:days]
        time_slot = TimeSlot.new(params[:time_slot])
        time_slot.location_id = location_id
        time_slot.start = date + day.to_i.days + time_slot.start.seconds_since_midnight
        time_slot.end = date + day.to_i.days + time_slot.end.seconds_since_midnight
        if !time_slot.save
          errors << "Error saving timeslot for #{WEEK_DAYS[day]}"
        end
      end
    end
    if errors.empty?
      flash[:notice] = "Successfully created timeslot(s)."
    else
      flash[:error] =  "Error: "+errors*"<br/>" 
    end
    redirect_to time_slots_path
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

