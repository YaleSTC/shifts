class PunchClocksController < ApplicationController
  def index
    require_department_admin
    @punch_clocks = PunchClock.find_all_by_department_id(current_department.id)
  end
  
  def show
    @punch_clock = PunchClock.find(params[:id])
    return unless require_owner(@punch_clock)
  end
  
  def create
    @punch_clock = PunchClock.new
    @punch_clock.user = current_user
    @punch_clock.department = @department
    @punch_clock.save ? flash[:notice] = "Successfully clocked in." : flash[:error] = "Could not clock in."
    redirect_to dashboard_url
  end

  def clock_out
    PunchClock.find(params[:id])
  end
  
  def edit
    @punch_clock = PunchClock.find_by_id(params[:id])
    return unless require_owner_or_dept_admin(@punch_clock)
  end
  
  # Clocks out the punch clock
  def update
    @punch_clock = PunchClock.find(params[:id])
    return unless require_owner_or_dept_admin(@punch_clock, @punch_clock.department)
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
  end  
  
# Cancels out the punch clock w/o adding time to payform
  def destroy
    @punch_clock = PunchClock.find(params[:id])
    return unless require_owner_or_dept_admin(@punch_clock, @punch_clock.department)
    @punch_clock.destroy if (@punch_clock = current_user.punch_clock) && request.post?
    redirect_to :controller => "/dashboard"
  end
  
end
