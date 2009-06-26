class PunchClocksController < ApplicationController
  def index
    @punch_clocks = PunchClock.all
  end
  
  def show
    @punch_clock = PunchClock.find(params[:id])
  end
  
  def new
    @user = User.find(params[:user_id])
    @punch_clock = PunchClock.new
  end
  
  def create
    @punch_clock = PunchClock.new(params[:punch_clock])
    @user = User.find(params[:user_id])
    @punch_clock.user = @user
    if @punch_clock.save
      flash[:notice] = "Successfully created punchclock."
      redirect_to @user
    else
      render :action => 'new'
    end
  end
  
  def destroy
    @user = User.find(params[:user_id])
    @punch_clock = PunchClock.find(params[:id])
    @punch_clock.destroy
    flash[:notice] = "Successfully destroyed punchclock."
    redirect_to user_punch_clocks_path(@user)
  end
end
