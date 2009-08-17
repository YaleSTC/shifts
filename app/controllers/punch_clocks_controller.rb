class PunchClocksController < ApplicationController
  layout "payforms"

  def index
    require_department_admin
    @punch_clocks = (params[:user_id] ? [current_user.punch_clock].compact : PunchClock.find_all_by_department_id(current_department.id))
  end

  def create
    @punch_clock = PunchClock.new({:user => current_user, :department => current_department, :runtime => 0, :last_touched => Time.now})
    @punch_clock.save ? flash[:notice] = "Successfully clocked in." : flash[:error] = "Could not clock in." + "<br/>" + @punch_clock.errors.full_messages.join("\n")
    redirect_to dashboard_url
  end
  
  def edit
    @punch_clock = PunchClock.find_by_id(params[:id])
    return unless require_owner_or_dept_admin(@punch_clock, @punch_clock.department)
  end
  
# Stops, restarts, or submits the punch clock depending on params
  def update
    @punch_clock = PunchClock.find(params[:id])
    return unless require_owner_or_dept_admin(@punch_clock, @punch_clock.department)
    if params[:pause]
      message = @punch_clock.pause
    elsif params[:unpause]
      message = @punch_clock.unpause
    elsif params[:punch_clock]  # Clocking out  
      message = @punch_clock.submit(params[:punch_clock][:description])
      message ||= "Successfully clocked out."
    end
    @punch_clock.last_touched = Time.now unless params[:punch_clock]
    if @punch_clock && @punch_clock.save || !@punch_clock
      flash[:notice] = message
    else
      flash[:error] = message
    end
    redirect_to current_user == @punch_clock.user ? dashboard_path : punch_clocks_path
  end  
  
# Cancels out the punch clock w/o adding time to payform
  def destroy
    @punch_clock = PunchClock.find(params[:id])
    return unless require_owner_or_dept_admin(@punch_clock, @punch_clock.department)
    if @punch_clock.destroy
      flash[:notice] = "Successfully canceled punch clock."
    else 
      flash[:error] = "Could not cancel punch clock."
    end
    redirect_to current_user == @punch_clock.user ? dashboard_path : punch_clocks_path  
  end
  
end
