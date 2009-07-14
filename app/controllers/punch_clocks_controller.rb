class PunchClocksController < ApplicationController
  def index
    @punch_clocks = PunchClock.all
  end
  
  def show
    @punch_clock = PunchClock.find(params[:id])
  end
  
  def new
    @user = current_user
    @punch_clock = PunchClock.new(params[:id])
    @punch_clock.user = @user
    if @punch_clock.save
      flash[:notice] = "Successfully clocked in."
    else
      flash[:notice] = "Could not clock in."  # why?
    end
    redirect_to dashboard_url
  end
  
  def create
    raise penguins
    @punch_clock = PunchClock.new(params[:punch_clock])
    @user = User.find(params[:user_id])
    @punch_clock.user = @user
    if @punch_clock.save
      flash[:notice] = "Successfully created punchclock."
      redirect_to dashboard_url
    else
      render :action => 'new'
    end
  end

  def clock_out
    PunchClock.find(params[:id])
  end
  
  def cancel
    if (clock = current_user.punch_clock) && request.post?
      clock.destroy
    end
    redirect_to :controller => "/dashboard"
  end
  
  def edit
    @punch_clock = current_user.punch_clock
  end
  
  def update  # I really want this method to be called 'destroy'
    @punch_clock = PunchClock.find(params[:id])
    @user = @punch_clock.user
    @time_in_hours = (Time.now - @punch_clock.created_at) / 3600.0  # sec -> hr
    @payform_item = PayformItem.new({:date => Date.today,
                                    :category => Category.find_by_name("Punch Clocks"),
                                    :hours => @time_in_hours,
                                    :description => params[:punch_clock]['description']})
    @payform = Payform.build(current_department, @user, Date.today)
    @payform_item.payform = @payform
    # @payform_item.save
    if @payform_item.save && @punch_clock.destroy
      flash[:notice] = "Successfully clocked out"
    else
      flash[:notice] = "Could not clock out"
      redirect_to dashboard_path and return
    end
    if current_user == @punch_clock.user
      redirect_to dashboard_path
    else
      redirect_to punch_clocks_path
    end
  end
end
