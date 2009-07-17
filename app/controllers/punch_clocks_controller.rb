class PunchClocksController < ApplicationController
  def index
    @punch_clocks = PunchClock.find_all_by_department(@department)
  end
  
  def show
    @punch_clock = PunchClock.find(params[:id])
    require_owner(@punch_clock)
  end
  
  # slated for removal -ben
#  def new
##    @user = current_user
#    @punch_clock = PunchClock.new(params[:id])
#    @punch_clock.user = current_user
#    if @punch_clock.save
#      flash[:notice] = "Successfully clocked in."
#    else
#      flash[:notice] = "Could not clock in."
#    end
#    redirect_to dashboard_url
#  end
  
  def create
    @punch_clock = PunchClock.new
    @punch_clock.user = current_user
    @punch_clock.save ? flash[:notice] = "Successfully clocked in." : flash[:error] = "Could not clock in."
    redirect_to dashboard_url
  end

  def clock_out
    PunchClock.find(params[:id])
  end
  
  # Currently not implemented
#  def cancel
#    if (clock = current_user.punch_clock) && request.post?
#      clock.destroy
#    end
#    redirect_to :controller => "/dashboard"
#  end
  
  def edit
    @punch_clock = current_user.punch_clock
    require_owner(@punch_clock, "You are not the owner of this punch clock.")
  end
  
  # Clocks out the punch clock
  def update  # I really want this method to be called 'destroy'
    @punch_clock = PunchClock.find(params[:id])
    require_owner_or_dept_admin(@punch_clock, "You are not the owner of this punch clock.")
    payform_item = PayformItem.new({:date => Date.today,
                                    :category => Category.find_by_name("Punch Clocks"),
                                    :hours => (Time.now - @punch_clock.created_at) / 3600.0, # sec -> hr
                                    :description => params[:punch_clock][:description]})
    payform_item.payform = Payform.build(@punch_clock.department, @punch_clock.user, Date.today)
    if payform_item.save && @punch_clock.destroy 
      flash[:notice] = "Successfully clocked out." 
      redirect_to(current_user == @punch_clock.user ? dashboard_path : punch_clocks_path)
    else
      flash[:notice] = "Could not clock out."
      render(:action => :edit)
    end
#    if payform_item.save && @punch_clock.destroy
#      flash[:notice] = "Successfully clocked out"
#    else
#      flash[:notice] = "Could not clock out"
#      redirect_to dashboard_path and return
#    end
#    if current_user == @punch_clock.user
#      redirect_to dashboard_path
#    else
#      redirect_to punch_clocks_path
#    end
  end
end
