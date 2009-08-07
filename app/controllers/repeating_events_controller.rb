class RepeatingEventsController < ApplicationController
  def index
    @repeating_events = RepeatingEvent.all
  end

  def show
    @repeating_event = RepeatingEvent.find(params[:id])
  end

  def new
    @repeating_event = RepeatingEvent.new
    @time_slot = TimeSlot.new
    @shift = Shift.new
  end

  def create
    params[:repeating_event][:days] = params[:days]
    params[:time_slot]["end(1i)"] = params[:shift]["end(1i)"] = params[:time_slot]["start(1i)"] = params[:shift]["start(1i)"] =  params[:repeating_event]["start_date(1i)"]
    params[:time_slot]["end(2i)"] = params[:shift]["end(2i)"] = params[:time_slot]["start(2i)"] = params[:shift]["start(2i)"] =  params[:repeating_event]["start_date(2i)"]
    params[:time_slot]["end(3i)"] = params[:shift]["end(3i)"] = params[:time_slot]["start(3i)"] = params[:shift]["start(3i)"] =  params[:repeating_event]["start_date(3i)"]
    @repeating_event = RepeatingEvent.new(params[:repeating_event])
    @time_slot = TimeSlot.new(params[:time_slot])
    @shift = Shift.new(params[:shift])
    if @repeating_event.save
      if @repeating_event.has_time_slots?
        TimeSlot.make_future(@repeating_event.end_date, @repeating_event.calendar.id, @repeating_event.id, @repeating_event.days_int, params[:location_ids], @time_slot.start, @time_slot.end)
      else
        Shift.make_future(@repeating_event.end_date, @repeating_event.calendar.id, @repeating_event.id, @repeating_event.days_int, @shift.location.id, @shift.start, @shift.end, @shift.user.id, @department.id)
      end
      flash[:notice] = "Successfully created repeating event."
      redirect_to @repeating_event
    else
      render :action => 'new'
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
