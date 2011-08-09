class UserConfigsController < ApplicationController
  before_filter :set_var_and_check_owner
  
  def edit
    @dept_select = current_user.departments.map{|d| [d.name, d.id]}
    @departments = current_user.departments
    current_user.departments.each do |dept|
      @data_objects = dept.data_objects
      @data_types = dept.data_types
    end
    if @user_config.read_attribute(:view_loc_groups)
      @selected_loc_groups = @user_config.read_attribute(:view_loc_groups).split(', ').map{|lg| lg.to_i }
    else
      @selected_loc_groups = []
    end
    
    if @user_config.watched_data_objects
      @selected_data_objects = @user_config.watched_data_objects.split(', ').map{|obj| obj.to_i }
    else
      @selected_data_objects = []
    end  

    @loc_groups_grouped_by_dept = []
      @departments.each do |dept|
        @loc_groups_list = []
        dept.loc_groups.each do |loc_group|
          @loc_groups_list << [loc_group.name, loc_group.id, @selected_loc_groups.include?(loc_group.id)]
        end
      @loc_groups_grouped_by_dept << [dept.name, @loc_groups_list]
      end
    
    @data_objects_grouped_by_type = []
      @data_types.each do |data_type|
        @data_objects_list = []
        data_type.data_objects.each do |data_object|
          @data_objects_list << [data_object.name, data_object.id, @selected_data_objects.include?(data_object.id)]
        end
        @data_objects_grouped_by_type << [data_type.name, @data_objects_list]
      end
  end


  def update
    if params[:loc]
      params[:user_config][:view_loc_groups] = params[:loc].keys.join(", ")
    else
      params[:user_config][:view_loc_groups] = []
    end
    if params[:dt]
      params[:user_config][:watched_data_objects] = params[:dt].keys.join(", ")
    else
      params[:user_config][:watched_data_objects] = []
    end
    # adding watched data objects to the params hash
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
