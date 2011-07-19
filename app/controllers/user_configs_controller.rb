class UserConfigsController < ApplicationController
  before_filter :set_var_and_check_owner

  def edit
    @dept_select = current_user.departments.map{|d| [d.name, d.id]}
    @loc_group_select = {}
    @data_objects = []
    current_user.departments.each do |dept|
      @loc_group_select.store(dept.id, current_user.loc_groups(dept))
      @data_objects << dept.data_objects
      @data_objects.flatten!
    end
    @selected_loc_groups = @user_config.view_loc_groups.collect{|lg| lg.id }
    @selected_data_objects = @user_config.watched_data_objects.split(', ').map{|obj| obj.to_i }
  end

  def update
    if params[:commit] == "Submit"
    	if @user_config.update_attributes(params[:user_config])
    	  flash[:notice] = "Successfully updated user settings."
    	  # if we came here from somewhere else, redirect us back
    	  redirect_to (params[:redirect_to] ? params[:redirect_to] : edit_user_config_path)
    	else
    	  render :action => 'edit'
    	end
		elsif params[:commit] == "Reset"
  		@users = User.all
  
 			for user in @users
 				if (Department.find_by_id(user.user_config.default_dept) == current_department)
 					this_user_config = user.user_config
  		    this_user_config.send_due_payform_email = true
  		    this_user_config.save
  			end
  		end
  		redirect_to (params[:redirect_to] ? params[:redirect_to] : edit_user_config_path)
		end
	end

	private

  def set_var_and_check_owner
    @user_config = UserConfig.find(params[:id])
    return unless user_is_owner_of(@user_config)
  end
end
