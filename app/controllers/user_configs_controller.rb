class UserConfigsController < ApplicationController   
  before_filter :check_user

  def edit
    @user_config = UserConfig.find(params[:id])
    @dept_select = current_user.departments.map{|d| [d.name, d.id]}
    @loc_group_select = {}
    current_user.departments.each do |dept|
      @loc_group_select.store(dept.id, current_user.loc_groups(dept))
    end    
    @selected_loc_groups = @user_config.view_loc_groups.split(', ').map{|lg|LocGroup.find(lg).id}
  end
  
  def update
    @user_config = UserConfig.find(params[:id])
    if @user_config.update_attributes(params[:user_config])
      flash[:notice] = "Successfully updated user config."
      redirect_to edit_user_config_path
    else
      render :action => 'edit'
    end
  end
  
  private 
  
  def check_user
    unless  current_user.is_superuser? || current_user == @user_config.user
      flash[:error] = "You do not have the authority to edit that user's settings."
      redirect_to root_path
    end
  end
  
end
