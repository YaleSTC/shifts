class DepartmentConfigsController < ApplicationController
  before_filter :check_user

  def edit
    @select_dept = DepartmentConfig.find(params[:id]).department.name
    @department_config = DepartmentConfig.find(params[:id])
    #@time_choices = (0..1440).step(@department_config.time_increment).map{|t| [t.min_to_am_pm, t]}
    #I'm hardcoding this as an hourly step, at least for now. -ryan
    @time_choices = (0..1440).step(60).map{|t| [t.min_to_am_pm, t]}
  end

  def update
    if @department_config.update_attributes(params[:department_config])
      @department_config.calibrate_time
      flash[:notice] = "Successfully updated department settings."
      redirect_to (params[:redirect_to] ? params[:redirect_to] : edit_department_config_path)
    else
      render :action => 'edit'
    end
  end

private

  def check_user
    @department_config = DepartmentConfig.find(params[:id])
    unless  current_user.is_superuser?
      flash[:error] = "You do not have the authority to edit department settings."
      redirect_to root_path
    end
  end
end

