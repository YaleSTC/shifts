class TimeSlotsController < ApplicationController
  before_filter :require_department_admin
  layout 'shifts'

  def index
    @period_start = params[:date] ? Date.parse(params[:date]).previous_sunday : Date.today.previous_sunday
    #TODO:simplify this stuff:
    @dept_start_hour = current_department.department_config.schedule_start / 60
    @dept_end_hour = current_department.department_config.schedule_end / 60
    @hours_per_day = (@dept_end_hour - @dept_start_hour)
    @block_length = current_department.department_config.time_increment
    @blocks_per_hour = 60/@block_length.to_f
    @blocks_per_day = @hours_per_day * @blocks_per_hour
    @hidden_timeslots = [] #for timeslots that don't show up on the view
  end

  def show
    @time_slot = TimeSlot.find(params[:id])
  end

  def new
    @time_slot = TimeSlot.new
    @period_start = params[:date] ? Date.parse(params[:date]).previous_sunday : Date.today.previous_sunday
  end

  def create
    errors = []
    date = params[:date] ? Date.parse(params[:date]).previous_sunday : Date.today.previous_sunday
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
      if params[:wants] #AJAX (jEditable)
        respond_to do |format|
          format.js
        end
      else
        flash[:notice] = "Successfully updated timeslot."
        redirect_to @time_slot
      end
    else
      render :action => 'edit'
    end
  end

  def destroy
    @time_slot = TimeSlot.find(params[:id])
    @time_slot.destroy
    respond_to do |format|
      format.html {flash[:notice] = "Successfully destroyed timeslot."; redirect_to time_slots_url}
      format.js #remove partial from view
    end
  end
  
  def rerender
    #@period_start = params[:date] ? Date.parse(params[:date]) : Date.today.end_of_week-1.week
    #TODO:simplify this stuff:
    @dept_start_hour = current_department.department_config.schedule_start / 60
    @dept_end_hour = current_department.department_config.schedule_end / 60
    @hours_per_day = (@dept_end_hour - @dept_start_hour)
    #@block_length = current_department.department_config.time_increment
    #@blocks_per_hour = 60/@block_length.to_f
    #@blocks_per_day = @hours_per_day * @blocks_per_hour
    #@hidden_timeslots = [] #for timeslots that don't show up on the view
    @time_slot = TimeSlot.find(params[:id])
    respond_to do |format|
      format.js
    end
  end
end

