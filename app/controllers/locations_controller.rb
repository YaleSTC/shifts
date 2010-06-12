class LocationsController < ApplicationController
  before_filter :find_allowed_locations

  def index
    redirect_to access_denied_path if current_user.loc_groups_to_admin(@department).empty?
    @location = Location.new #for embedded form at page bottom
  end

  def show
    @location = Location.find(params[:id])
    redirect_to access_denied_path unless @locations.include?(@location)
  end

  def new
    @location = Location.new
  end 

  def create
    @location = Location.new(params[:location])
    if !current_user.loc_groups_to_admin(@department).include?(@location.loc_group)  
      flash[:error] = "You do not have permission to create locations in that location group."
      redirect_to :action => "new"   
    elsif @location.save
      flash[:notice] = "Successfully created location."
      redirect_to department_locations_path(current_department)
    else
      render :action => 'new'
    end
  end

  def edit
    @location = Location.find(params[:id])
    redirect_to access_denied_path unless @locations.include?(@location)
  end

  def update
    @location = Location.find(params[:id])
    redirect_to access_denied_path unless @locations.include?(@location)
    if @location.update_attributes(params[:location])
      flash[:notice] = "Successfully updated location."
      redirect_to @location
    else
      render :action => 'edit'
    end
  end

  def toggle
    #raise params.to_yaml
    @location = Location.find(params[:id])
    @shifts = Shift.in_location(@location).select{|s| s.start > Time.now}
    #Should we wrap all this into a transaction as is done in Calendar?
    @location.toggle_active
    @shifts.each do |shift|
      if shift.active
        shift.active = false
      elsif shift.user.is_active?(current_department) && shift.calendar.active
        shift.active = true
      else 
        shift.active = false
      end
      shift.save
    end
    flash[:notice] = "Changed activation status of " + @location.name.to_s + "."
    redirect_to department_locations_path(current_department)
  end

  def destroy
     @location = Location.find(params[:id])
     redirect_to access_denied_path unless @locations.include?(@location)
     @location.destroy
     flash[:notice] = "Successfully destroyed location."
     redirect_to department_locations_path(current_department)
   end
  
private

  def find_allowed_locations
    @locations = current_user.loc_groups_to_admin(@department).map{|lg| lg.locations}.flatten
  end

end

