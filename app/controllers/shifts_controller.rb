class ShiftsController < ApplicationController
  def index
    @shifts = Shift.all
    current_user_locations = current_user.departments.collect{|d| d.locations}.flatten
    @current_shifts = Shift.all.select{|s| s.report and !s.submitted? and current_user_locations.include?(s.location)}.sort_by(&:start)
    @period_start = params[:date].blank? ? Date.parse("last Sunday") : Date.parse(params[:date])
    @days_per_period = 7 #TODO: make this a setting for an admin
    @show_weekends = false
  end

  def show
    @shift = Shift.find(params[:id])
  end

  def new
    @shift = Shift.new(params[:shift])
  end

  def unscheduled
    @shift = Shift.new
  end

  def power_sign_up
    @shift = Shift.new
  end

  def create
    @shift = Shift.new(params[:shift])
    @shift.start = Time.now unless @shift.start
    unless current_user.is_admin_of?(@department) && @shift.scheduled?
      @shift.power_signed_up = false
      @shift.user = current_user
    end
    if @shift.save
      #combine with any compatible shifts (if the shift is scheduled)
      flash[:notice] = "Successfully created shift."
      redirect_to @shift
    else
      render :action => 'new'
    end
  end

  def edit
    @shift = Shift.find(params[:id])
  end

  def update
    @shift = Shift.find(params[:id])
    if @shift.update_attributes(params[:shift])
      #combine with any compatible shifts
      flash[:notice] = "Successfully updated shift."
      redirect_to @shift
    else
      render :action => 'edit'
    end
  end

  def destroy
    @shift = Shift.find(params[:id])
    @shift.destroy
    flash[:notice] = "Successfully destroyed shift."
    redirect_to shifts_url
  end
end
