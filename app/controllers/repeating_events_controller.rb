class RepeatingEventsController < ApplicationController
  def index
    @repeating_events = RepeatingEvent.all
  end

  def show
    @repeating_event = RepeatingEvent.find(params[:id])
  end

  def new
    @repeating_event = RepeatingEvent.new
  end

  def create
    params[:repeating_event][:days] = params[:days]
    if params[:repeating_event][:slot_or_shift] == "time_slot"
      params[:repeating_event][:location_ids] = params[:location_ids]
    else
      params[:repeating_event][:location_ids] = [params[:shift][:location_id]]
    end
    params[:repeating_event]["end_time(1i)"]=  params[:repeating_event]["start_time(1i)"] =  params[:repeating_event]["start_date(1i)"]
    params[:repeating_event]["end_time(2i)"]=  params[:repeating_event]["start_time(2i)"] =  params[:repeating_event]["start_date(2i)"]
    params[:repeating_event]["end_time(3i)"]=  params[:repeating_event]["start_time(3i)"] =  params[:repeating_event]["start_date(3i)"]
    @repeating_event = RepeatingEvent.new(params[:repeating_event])
    wipe = params[:wipe] ? true : false
    begin
      ActiveRecord::Base.transaction do
        @repeating_event.save!
        @failed = @repeating_event.make_future(wipe)
        raise @failed if @failed
      end
      flash[:notice] = "Successfully created repeating event."
      redirect_to @repeating_event
    rescue Exception => e
      @errors = e.message.gsub("Validation failed:", "").split(",")
      @repeating_event = @repeating_event.clone
      render :action => 'new'
    end
    if @errors

    else
    end
  end

  def edit
    @repeating_event = RepeatingEvent.find(params[:id])
    @time_slot = TimeSlot.new
    @shift = Shift.new
  end

  def update
    @repeating_event = RepeatingEvent.find(params[:id])
    if @repeating_event.update_attributes(params[:repeating_event])
      flash[:notice] = "Successfully updated repeating event."
      redirect_to @repeating_event
    else
      render :action => 'edit'
    end
  end

  def destroy
    @repeating_event = RepeatingEvent.find(params[:id])
    RepeatingEvent.destroy_self_and_future(@repeating_event)
    flash[:notice] = "Successfully destroyed repeating event."
    redirect_to repeating_events_url
  end
end
