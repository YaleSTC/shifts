class ShiftsController < ApplicationController
  def index
    @shifts = Shift.all
    @current_shifts = Shift.all.select{|r| !r.submitted? and current_user.departments.collect{|d| d.locations}.flatten.include?(r.location)}.sort_by(&:start)
  end
  
  def show
    @shift = Shift.find(params[:id])
  end
  
  def new
    @shift = Shift.new
  end
  
  def unscheduled
    @shift = Shift.new
  end
  
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
