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
    @repeating_event = RepeatingEvent.new(params[:repeating_event])
    if @repeating_event.save
      flash[:notice] = "Successfully created repeating event."
      redirect_to @repeating_event
    else
      render :action => 'new'
    end
  end

  def edit
    @repeating_event = RepeatingEvent.find(params[:id])
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
    @repeating_event.destroy
    flash[:notice] = "Successfully destroyed repeating event."
    redirect_to repeating_events_url
  end
end
