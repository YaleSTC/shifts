class LocGroupsController < ApplicationController
  before_filter :require_department_admin, :except => [:index, :show, :edit, :update]
  before_filter :find_loc_group_and_check_admin, :only => [:show, :edit, :update]
  # Show, edit, and update will allow the loc_group_admin as well

  def index
    @loc_groups = current_department.loc_groups.select { |lg| current_user.is_admin_of?(lg) }
    @loc_group = LocGroup.new({:department => current_department})
  end

  def show
  end

  def new
    @loc_group = @department.loc_groups.build
  end

  def create
    @loc_group = LocGroup.new(params[:loc_group])
    if @loc_group.save
      flash[:notice] = "Successfully created location group."
      redirect_to @loc_group
    else
      render :action => 'new'
    end
  end

  def edit     
  end

  def update
    if @loc_group.update_attributes(params[:loc_group])
      flash[:notice] = "Successfully updated Location group."
      redirect_to @loc_group
    else
      render :action => 'edit'
    end
  end

  def destroy
    @loc_group = LocGroup.find(params[:id])
    @loc_group.destroy
    flash[:notice] = "Successfully destroyed Location group."
    redirect_to department_loc_groups_path(current_department)
  end    
      
private
  
  def find_loc_group_and_check_admin
    @loc_group = LocGroup.find(params[:id])
    require_loc_group_admin(@loc_group)
  end
  
end

