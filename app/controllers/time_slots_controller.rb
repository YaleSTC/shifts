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
    @period_start = params[:date] ? Date.parse(params[:date]).previous_sunday.to_date : Date.today.previous_sunday.to_date
  end

  def create
    errors = []
    parse_date_and_time_output(params[:time_slot])
    @time_slot = TimeSlot.new(params[:time_slot])
    @time_slot.join_date_and_time

    if !@time_slot.save
      errors << "Error saving timeslot"
    end

    respond_to do |format|
      format.html do
          if errors.empty?
            flash[:notice] = "Successfully created timeslot(s)."
          else
            flash[:error] =  "Error: "+errors*"<br/>"
          end
          redirect_to time_slots_path
      end
      format.js do
          if errors.empty?
            @dept_start_hour = current_department.department_config.schedule_start / 60
            @dept_end_hour = current_department.department_config.schedule_end / 60
            @hours_per_day = (@dept_end_hour - @dept_start_hour)
          else
            render :update do |page|
              ajax_alert(page, "<strong>error:</strong> timeslot could not be saved<br>"+errors*"<br/>")
            end
          end
      end
    end
  end

  def edit
    @time_slot = TimeSlot.find(params[:id])
  end

  def update
    @time_slot = TimeSlot.find(params[:id])
    parse_date_and_time_output(params[:time_slot])

    if @time_slot.update_attributes(params[:time_slot])
      respond_to do |format|
        format.js
        format.html do
          flash[:notice] = "Successfully updated timeslot."
          redirect_to @time_slot
        end
      end
    else
      respond_to do |format|
        format.js do
          render :update do |page|
            error_string = ""
            @time_slot.errors.each do |attr_name, message|
              error_string += "<br><br>#{attr_name}: #{message}"
            end
            ajax_alert(page, "<strong>error:</strong> updated time slot could not be saved."+error_string, 2.5 + (@time_slot.errors.size))
          end
        end
        format.html {render :action => 'edit'}
      end
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
end

