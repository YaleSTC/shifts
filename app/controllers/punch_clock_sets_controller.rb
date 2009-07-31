class PunchClockSetsController < ApplicationController
  layout "payforms"
  
  before_filter :require_department_admin

  def index
    @punch_clock_sets = PunchClockSet.all
  end

  def show
    @punch_clock_set = PunchClockSet.find(params[:id])
  end

  def new
    @punch_clock_set = PunchClockSet.new
  end

  def edit
    @punch_clock_set = PunchClockSet.find(params[:id])
  end

  def create
    @punch_clock_set = PunchClockSet.new(params[:punch_clock_set])
    if @punch_clock_set.save
      flash[:notice] = 'PunchClockSet was successfully created.'
      redirect_to(@punch_clock_set)
    else
      render :action => "new"
    end
  end

  def update
    @punch_clock_set = PunchClockSet.find(params[:id])
    if @punch_clock_set.update_attributes(params[:punch_clock_set])
      flash[:notice] = 'PunchClockSet was successfully updated.'
      redirect_to(@punch_clock_set)
    else
      render :action => "edit"
    end
  end

  def destroy
    @punch_clock_set = PunchClockSet.find(params[:id])
    @punch_clock_set.destroy
    redirect_to(punch_clock_sets_url)
  end

end
