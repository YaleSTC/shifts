class LocGroupsController < ApplicationController  
  before_filter :require_department_admin

  def index
    @loc_groups = @department.loc_groups.select { |lg| current_user.is_admin_of?(lg) }
    @loc_group = @department.loc_groups.build
  end

  def show
    @loc_group = LocGroup.find(params[:id])
  end

  def new
    @loc_group = @department.loc_groups.build
  end

  def create
    @loc_group = LocGroup.new(params[:loc_group])
    if @loc_group.save
      flash[:notice] = "Successfully created loc group."
      redirect_to @loc_group
    else
      render :action => 'new'
    end
  end

  def edit
    @loc_group = LocGroup.find(params[:id])
  end

  def update
    @loc_group = LocGroup.find(params[:id])
    if @loc_group.update_attributes(params[:loc_group])
      flash[:notice] = "Successfully updated loc group."
      redirect_to @loc_group
    else
      render :action => 'edit'
    end
  end

  def destroy
    @loc_group = LocGroup.find(params[:id])
    @loc_group.destroy
    flash[:notice] = "Successfully destroyed loc group."
    redirect_to department_loc_groups_path(current_department)
  end
end

