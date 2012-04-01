class RepeatingEventsController < ApplicationController
  before_filter :require_department_admin
  helper ShiftsHelper
  helper CalendarsHelper

  def index
    @repeating_events = RepeatingEvent.all
  end

  def show
    @repeating_event = RepeatingEvent.find(params[:id])
  end

  def new
    @repeating_event = RepeatingEvent.new
    @repeating_event.calendar_id = session[:calendar]
  end

  def create
    #TODO: persistent calendar selection? it would be nice...

    parse_date_and_time_output(params[:repeating_event])
    session[:calendar] = params[:repeating_event][:calendar_id]
    params[:repeating_event][:days] = params[:days]
    if params[:repeating_event][:slot_or_shift] == "time_slot"
      params[:repeating_event][:location_ids] = params[:for_locations]
    else
      params[:repeating_event][:location_ids] = [params[:shift][:location_id]]
    end
    @repeating_event = RepeatingEvent.new(params[:repeating_event])
    wipe = params[:wipe] ? true : false
    if params[:whole_calendar] && !@repeating_event.calendar.default
      @repeating_event.start_date = @repeating_event.calendar.start_date
      @repeating_event.end_date = @repeating_event.calendar.end_date
    end
    warn = @repeating_event.start_time <= Time.now
    begin
      ActiveRecord::Base.transaction do
        @repeating_event.save!
        @failed = @repeating_event.make_future(wipe)
        raise @failed if @failed
      end
      respond_to do |format|
        format.html {flash[:notice] = "Successfully created repeating event."; flash[:notice] += " Please note that some events were not created because they started in the past."; redirect_to @repeating_event}
        format.js
      end
    rescue Exception => e
      @errors = e.message.gsub("Validation failed:", "").split(",")
      @repeating_event = @repeating_event.clone
      respond_to do |format|
        format.html {render :action => 'new'}
        format.js do
          render :update do |page|
            persistent_ajax_alert(page, "<strong>Error:</strong> repeating event could not be saved.<br><br>"+(@errors.nil? ? e : @errors*"<br><br>"))
          end
        end
      end
    end
  end

  def edit
    @repeating_event = RepeatingEvent.find(params[:id])
  end

  def update
    @old_repeating_event = RepeatingEvent.find(params[:id])
    parse_date_and_time_output(params[:repeating_event])
    params[:repeating_event][:days] = params[:days]
    if params[:repeating_event][:slot_or_shift] == "time_slot"
      params[:repeating_event][:location_ids] = params[:for_locations]
    else
      params[:repeating_event][:location_ids] = [params[:shift][:location_id]]
    end
    @repeating_event = RepeatingEvent.new(params[:repeating_event])
    wipe = params[:wipe] ? true : false
    if params[:whole_calendar] && !@repeating_event.calendar.default
      @repeating_event.start_date = @repeating_event.calendar.start_date
      @repeating_event.end_date = @repeating_event.calendar.end_date
    end
    warn = @repeating_event.start_time <= Time.now
    begin
      ActiveRecord::Base.transaction do
        RepeatingEvent.destroy_self_and_future(@old_repeating_event)
        @repeating_event.save!
        @failed = @repeating_event.make_future(wipe)
        raise @failed if @failed
      end
      respond_to do |format|
        format.html {
          flash[:notice] = "Successfully edited repeating event."
          flash[:notice] += " Please note that some events were not created because they started in the past."
          redirect_to @repeating_event
        }
        format.js
      end
    rescue Exception => e
      @errors = e.message.gsub("Validation failed:", "").split(",")
      @repeating_event = @repeating_event.clone
      respond_to do |format|
        format.html {render :action => 'edit'}
        format.js do
          render :update do |page|
            persistent_ajax_alert(page, "<strong>Error:</strong> repeating event could not be saved.<br><br>"+(@errors.nil? ? e : @errors*"<br><br>"))
          end
        end
      end
    end
  end

  def destroy
    @repeating_event = RepeatingEvent.find(params[:id])
    if @repeating_event.is_set_of_timeslots? and !params[:calendar]
      @locations = @repeating_event.locations
    else
      @days = @repeating_event.days
    end
    ActiveRecord::Base.transaction do
      if params[:delete_after_date]
        RepeatingEvent.destroy_self_and_future(@repeating_event, Time.parse(params[:delete_after_date]))
      else
        RepeatingEvent.destroy_self_and_future(@repeating_event)
      end
    end
    respond_to do |format|
      format.html {flash[:notice] = "Successfully destroyed repeating event."; redirect_to repeating_events_url}
      format.js
    end
  end
end

