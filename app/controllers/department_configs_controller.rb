class DepartmentConfigsController < ApplicationController
  before_filter :require_department_admin

  def edit
    @time_choices = (0..1440).step(60).map{|t| [t.min_to_am_pm, t]}
    @department_config = DepartmentConfig.find(params[:id])
    @select_dept = @department_config.department.name
    #@time_choices = (0..1440).step(@department_config.time_increment).map{|t| [t.min_to_am_pm, t]}
    #I'm hardcoding this as an hourly step, at least for now. -ryan
  end

  def update
    raise params.to_yaml
    @department_config = DepartmentConfig.find(params[:id])
    if @department_config.update_attributes(params[:department_config])
      @department_config.calibrate_time
      flash[:notice] = "Successfully updated department settings."
      redirect_to (params[:redirect_to] ? params[:redirect_to] : edit_department_config_path)
    else
      @time_choices = (0..1440).step(60).map{|t| [t.min_to_am_pm, t]}
      render :action => 'edit'
    end
  end

end

