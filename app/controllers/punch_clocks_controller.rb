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
    @punch_clock = PunchClock.where(:id => params[:id]).first
    return unless user_is_owner_or_admin_of(@punch_clock, @punch_clock.department)
  end
  
# Stops, restarts, or submits the punch clock depending on params
  def update
    @punch_clock = PunchClock.find(params[:id])
    return unless user_is_owner_or_admin_of(@punch_clock, @punch_clock.department)
    if params[:pause]
      message = @punch_clock.pause || "Successfully paused punch clock."
    elsif params[:unpause]
      message = @punch_clock.unpause || "Successfully unpaused punch clock."
    elsif params[:punch_clock]  # Clocking out
      message = @punch_clock.submit(params[:punch_clock][:description])
      if message
        error = true
      else
        error = false
        message = "Successfully clocked out."
      end
    end
    @punch_clock.last_touched = Time.now unless params[:punch_clock]
    if @punch_clock && @punch_clock.save && !error
      flash[:notice] = message
    else
      flash[:error] = "Could not modify punch clock: #{message}."
    end
    redirect_to current_user == @punch_clock.user ? dashboard_path : punch_clocks_path
  end

# Cancels out the punch clock w/o adding time to payform
  def destroy
    @punch_clock = PunchClock.find(params[:id])
    return unless user_is_owner_or_admin_of(@punch_clock, @punch_clock.department)
    if @punch_clock.destroy
      flash[:notice] = "Successfully canceled punch clock."
    else
      flash[:error] = "Could not cancel punch clock."
    end
    redirect_to current_user == @punch_clock.user ? dashboard_path : punch_clocks_path
  end

end

