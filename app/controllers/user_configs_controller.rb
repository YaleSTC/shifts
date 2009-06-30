class UserConfigsController < ApplicationController   

  def edit
    @user_config = UserConfig.find(params[:id])
    unless  current_user == @user_config.user
      flash[:error] = "You do not have the authority to edit that user's settings."
      redirect_to root_path
    end
    @dept_select = current_user.departments.map{|d| [d.name, d.id]}
    @loc_group_select = {}
    current_user.departments.each do |dept|
      @loc_group_select.store(dept.id, current_user.loc_groups(dept))
    end    
  end
  
  def update
    @user_config = UserConfig.find(params[:id])
#    raise params.to_yaml
#    params[:user_config][:view_loc_groups] = params[:user_config][:view_loc_groups].join(", ")
#    raise params.to_yaml
    if @user_config.update_attributes(params[:user_config])
      flash[:notice] = "Successfully updated user config."
      raise @user_config.to_yaml
      redirect_to edit_user_config_path
    else
      render :action => 'edit'
    end
  end
  
end
