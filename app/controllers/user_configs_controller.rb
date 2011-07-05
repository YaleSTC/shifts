class UserConfigsController < ApplicationController
  before_filter :set_var_and_check_owner

  def edit
    @dept_select = current_user.departments.map{|d| [d.name, d.id]}
    @loc_group_select = {}
    current_user.departments.each do |dept|
      @loc_group_select.store(dept.id, current_user.loc_groups(dept))
      @data_objects = dept.data_objects
      @data_types = dept.data_types
    end
    @selected_loc_groups = @user_config.view_loc_groups.collect{|lg| lg.id }
    @selected_data_objects = @user_config.watched_data_objects.split(', ').map{|obj| obj.to_i }
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
    # adding watched data objects to the params hash
    params[:user_config][:watched_data_objects] = params[:dt].keys.join(",")
    if @user_config.update_attributes(params[:user_config])
      flash[:notice] = "Successfully updated user settings."
      # if we came here from somewhere else, redirect us back
      redirect_to (params[:redirect_to] ? params[:redirect_to] : edit_user_config_path)
    else
      render :action => 'edit'
    end
  end

  private

  def set_var_and_check_owner
    @user_config = UserConfig.find(params[:id])
    return unless user_is_owner_of(@user_config)
  end

end

