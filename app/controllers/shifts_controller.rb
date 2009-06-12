class ShiftsController < ApplicationController
  def index
    @shifts = Shift.all
    current_user_locations = current_user.departments.collect{|d| d.locations}.flatten
    @current_shifts = Shift.all.select{|s| s.report and !s.submitted? and current_user_locations.include?(s.location)}.sort_by(&:start)
    @period_start = params[:date].blank? ? Date.parse("last Sunday") : Date.parse(params[:date])
    @days_per_period = 7 #TODO: make this a setting for an admin
  end

  def show
    @shift = Shift.find(params[:id])
  end

  def new
    @shift = Shift.new
  end
<<<<<<< HEAD:app/controllers/shifts_controller.rb
  
  def unscheduled
    @shift = Shift.new
  end
  
=======

>>>>>>> 7e4d2d25d8debe6cd7e58d9708ea0b3bba6ed775:app/controllers/shifts_controller.rb
  def create
    @shift = Shift.new(params[:shift])
    @shift.start = Time.now unless @shift.start
    if @shift.save
      #combine with any compatible shifts (if the shift is scheduled)
      @shift = Shift.combine_with_surrounding_shifts(@shift)
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
      @shift = Shift.combine_with_surrounding_shifts(@shift)
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

