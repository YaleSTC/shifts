class UserConfigsController < ApplicationController   
  def edit
    @user_config = UserConfig.find(params[:id])
  end
  
  def update
    @user_config = UserConfig.find(params[:id])
    if params[:user_config]
      params[:user_config][:default_dept] = Department.find_by_name(params[:user_config][:default_dept])
      params[:user_config][:view_loc_groups] = params[:user_config][:view_loc_groups].split(',').map{|name|LocGroup.find_by_name(name).id}
    end
    if @user_config.update_attributes(params[:user_config])
      flash[:notice] = "Successfully updated user config."
      redirect_to edit_user_config_path
    else
      render :action => 'edit'
    end
  end
  
end
