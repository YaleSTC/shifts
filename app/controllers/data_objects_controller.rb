class DataObjectsController < ApplicationController

# Needs views revised for non-ajax degradeability -ben
  def index   
    @data_objects = @department.data_objects
    @group_type_options = options_for_group_type
    @group_by_options = []
    @selected_type = "departments"
    if params[:group_type]
      @selected_type = params[:group_type]
      if params[:group_by] && !params[:group_by].blank?
        @selected_by = params[:group_by]
        @data_objects &= @selected_type.classify.constantize.find(@selected_by).data_objects
      end
      @group_by_options = options_for_group_by(@selected_type)
    end
    @types_objects_hash = @data_objects.group_by &:data_type
    respond_to do |format|
      format.html
      format.js
    end
  end
  
# This needs its views rewritten to enable viewing a subset of all entries -ben  
  def show
    @data_object = DataObject.find(params[:id])   
    require_department_membership(@data_object.department)
    @data_fields = @data_object.data_type.data_fields
    @data_entries = @data_object.data_entries
  end
  
  def new
    @data_object = DataObject.new
    @data_object.data_type_id = params[:data_type_id] if params[:data_type_id]
    @locations_select = options_for_location_select
  end
  
  def create
    @data_object = DataObject.new(params[:data_object])
    @data_object.data_type_id = params[:data_type_id] if params[:data_type_id]
    check_data_object_admin_permission(@data_object)    
    if @data_object.save
      flash[:notice] = "Successfully created data object."
      redirect_to (params[:add_another] ? new_data_type_data_object_path(@data_object.data_type) : data_objects_path)
    else
      @locations_select = options_for_location_select
      render :action => 'new'
    end
  end
  
  def edit
    @data_object = DataObject.find(params[:id])
    @locations_select = current_user.loc_groups_to_admin(@department).map{|lg| lg.locations}.flatten
    check_data_object_admin_permission(@data_object)    
  end
  
  def update
    @data_object = DataObject.find(params[:id])
    check_data_object_admin_permission(@data_object)    
    if @data_object.update_attributes(params[:data_object])
      flash[:notice] = "Successfully updated data object."
      redirect_to @data_object
    else
      render :action => 'edit'
    end
  end
  
  def destroy
    @data_object = DataObject.find(params[:id])
    check_data_object_admin_permission(@data_object)    
    @data_type = @data_object.data_type
    @data_object.destroy
    flash[:notice] = "Successfully destroyed data object."
    redirect_to data_type_path(@data_type)
  end
   
private

# Currently not in use -ben
# Returns all the data objects that the user is permitted to administer
# other methods should grab these objects, and narrow them down
#  def get_allowed_data_objects
#    return @department.data_objects if current_user.is_admin_of?(@department)
#    unless (@loc_groups = current_user.loc_groups_to_admin(@department)).empty?
#      @loc_groups.map{|lg| DataObject.by_location_group(lg)}.flatten    
#    else
#      flash[:error] = "You do not have the permissions necessary to view any
#                      data objects."
#      redirect_to access_denied_path
#    end
#  end
  
  #These three options should probably be refactored into helper methods -ben
  def options_for_group_type
    options = [["Location","locations"],["Location Group","loc_groups"]]
    if current_user.is_admin_of?(@department)
      options.push(["Data type", "data_types"], ["Department", "departments"])
    end
  end 

  #These three options should probably be refactored into helper methods -ben
  def options_for_group_by(group_type)
    return [] if group_type == "departments"
    @options = @department.send(group_type)
    if group_type == "locations" || group_type == "loc_groups" 
      @options.delete_if{|opt| !current_user.is_admin_of?(opt)}
    end
    @options.map{|t| [t.name, t.id]} << []
  end

  #These three options should probably be refactored into helper methods -ben
  def options_for_location_select
    current_user.loc_groups_to_admin(@department).map{|lg| lg.locations}.flatten
  end
  
  def check_data_object_admin_permission(obj)
    if (current_user.loc_groups_to_admin(@department).map{|lg| lg.locations}.flatten & obj.locations).empty?
      flash[:notice] = "You do not have permission to administer this data object"
      redirect_to access_denied_path
    end
  end

end
