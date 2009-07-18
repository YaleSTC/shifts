class UserConfigsController < ApplicationController
  before_filter :set_var_and_check_owner

  def edit
    @dept_select = current_user.departments.map{|d| [d.name, d.id]}
    @loc_group_select = {}
    current_user.departments.each do |dept|
      @loc_group_select.store(dept.id, current_user.loc_groups(dept))
    end
    @selected_loc_groups = @user_config.view_loc_groups.split(', ').map{|lg|LocGroup.find(lg).id}
  end

  def update
    if @user_config.update_attributes(params[:user_config])
      flash[:notice] = "Successfully updated user config."
      # if we came here from somewhere else, redirect us back
      redirect_to (params[:redirect_to] ? params[:redirect_to] : edit_user_config_path)
    else
      render :action => 'edit'
    end
  end

  private

  def set_var_and_check_owner
    @user_config = UserConfig.find(params[:id])
    require_owner(@user_config)
  end

end
