class PunchClocksController < ApplicationController

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
      @punch_clock.paused = true
      @punch_clock.runtime += Time.now - @punch_clock.last_touched
    elsif params[:unpause]
      @punch_clock.paused = false
    elsif params[:punch_clock]  # Clocking out  
      payform_item = PayformItem.new({:date => Date.today,
                                      :category => Category.find_by_name("Punch Clocks"),
                                      :hours => (@punch_clock.runtime/3600), # sec -> hr
                                      :description => params[:punch_clock][:description]})
      payform_item.payform = Payform.build(@punch_clock.department, @punch_clock.user, Date.today)
      begin
        if (payform_item.save! && @punch_clock.destroy)
          flash[:notice] = "Successfully clocked out."
          redirect_to dashboard_path and return
        end
      rescue Exception => e
        flash[:error] = e.message
        render :edit and return
      end
    end
    @punch_clock.last_touched = Time.now
    flash[:notice] = @punch_clock && @punch_clock.save ? "Successfully modified punch clock." : "Could not modify punch clock."
    redirect_to current_user == @punch_clock.user ? dashboard_path : punch_clocks_path
  end  
  
# Cancels out the punch clock w/o adding time to payform
  def destroy
    @punch_clock = PunchClock.find(params[:id])
    return unless require_owner_or_dept_admin(@punch_clock, @punch_clock.department)
    flash[:notice] = @punch_clock.destroy ? "Successfully canceled punch clock." : "Could not cancel punch clock."
    redirect_to :controller => "/dashboard"
  end
  
end
