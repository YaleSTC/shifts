class PunchClocksController < ApplicationController
  def index
    @punch_clocks = PunchClock.all
  end
  
  def show
    @punch_clock = PunchClock.find(params[:id])
  end
  
  def new
    @punch_clock = PunchClock.new
  end
  
  def create
    @punch_clock = PunchClock.new(params[:punch_clock])
    if @punch_clock.save
      flash[:notice] = "Successfully created punchclock."
      redirect_to @punch_clock
    else
      render :action => 'new'
    end
  end
  
  def destroy
    @punch_clock = PunchClock.find(params[:id])
    @punch_clock.destroy
    flash[:notice] = "Successfully destroyed punchclock."
    redirect_to punch_clocks_url
  end
end
