class TimeSlotsController < ApplicationController
  before_filter :require_department_admin

  def index
    @time_slots = TimeSlot.all
  end

  def show
    @time_slot = TimeSlot.find(params[:id])
  end

  def new
    @time_slot = TimeSlot.new
  end

  def create
    @time_slot = TimeSlot.new(params[:time_slot])
    if @time_slot.save
      flash[:notice] = "Successfully created timeslot."
      redirect_to @time_slot
    else
      render :action => 'new'
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

