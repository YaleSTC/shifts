class DataObjectsController < ApplicationController
  helper :data_entries

# Needs views revised for non-ajax degradeability -ben
# Note: there are good reasons not to do this by merely hiding the group_by divs
  def index
    @data_objects = current_department.data_objects
    @group_type_options = options_for_group_type
    @group_by_options = []
    @selected_type = ["Department", "departments"]
    if params[:group_type]
      @group_by_options = options_for_group_by(params[:group_type])
      if params[:group_by] && !params[:group_by].blank?
        @data_objects &= params[:group_type].classify.constantize.find(params[:group_by]).data_objects
        @selected_by = @group_by_options.select{|opt| opt.include? params[:group_by].to_i}.flatten
      else
        @selected_by = @group_by_options.first
      end
      @selected_type = @group_type_options.select{|a|a.include? params[:group_type]}.flatten
    end
    @types_objects_hash = @data_objects.group_by &:data_type
    #this is for users who are not admins
    @personal_types_objects_hash = DataObject.find(current_user.user_config.watched_data_objects.split(', ')).group_by(&:data_type)
    respond_to do |format|
      format.html #{ update_page{|page| page.hide 'submit'}}
      format.js
    end
  end

  def show
    @data_object = DataObject.find(params[:id])
    require_department_membership(@data_object.department)
    @data_fields = @data_object.data_type.data_fields
    offset = params[:offset] || 0
    @start_date = 1.week.ago
    @end_date = Date.today
    if params[:start] && params[:end]
      @start_date = Date.civil(params[:start][:year].to_i, params[:start][:month].to_i, params[:start][:day].to_i)
      @end_date = Date.civil(params[:end][:year].to_i, params[:end][:month].to_i, params[:end][:day].to_i)
      @data_entries = DataEntry.for_data_object(@data_object).between_days(@start_date, @end_date)
    else
      @data_entries = DataEntry.where(:data_object_id => @data_object.id).limit(50).offset(offset).order("created_at DESC")
    end
  end

  def new
    @data_object = DataObject.new
    @data_object.data_type_id = params[:data_type_id] if params[:data_type_id]
    @locations_select = options_for_location_select
  end

  def create
    @data_object = DataObject.new(params[:data_object])
    @data_object.data_type_id = params[:data_type_id] if params[:data_type_id]
    return unless check_data_object_admin_permission(@data_object)
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

  def update_data_objects
    @report = current_user.current_shift.report if current_user.current_shift
    loc_groups = LocGroup.all
    @loc_groups = loc_groups.select{ |lg| lg.users.include?(current_user) }
    tasks = []
    @loc_groups.each do |loc_group|
      tasks << loc_group.locations.map{ |loc| loc.tasks }.flatten.uniq.compact
    end
    tasks = tasks.flatten.uniq.compact
    tasks = Task.active.after_now & tasks
    # filters out daily and weekly tasks scheduled for a time later in the day
    tasks = tasks.delete_if{|t| t.kind != "Hourly" && Time.now.seconds_since_midnight < t.time_of_day.seconds_since_midnight}
    # filters out weekly tasks on the wrong day
    @tasks = tasks.delete_if{|t| t.kind == "Weekly" && t.day_in_week != @report.shift.start.strftime("%a") }
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

  #These three options could maybe be refactored into helper methods -ben
  #This would require also refactoring the @selected_type & @selected_by vars
  def options_for_group_type
    options = [["Location","locations"],["Location Group","loc_groups"]]
    if current_user.is_admin_of?(current_department)
      options.push(["Data type", "data_types"], ["Department", "departments"]).sort
    end
    options
  end

  #These three options could maybe be refactored into helper methods -ben
  def options_for_group_by(group_type)
    return [] if group_type == "departments"
    @options = current_department.send(group_type)
    @options.map{|t| [t.name, t.id]}.sort
  end

  #These three options could maybe be refactored into helper methods -ben
  def options_for_location_select
    current_user.loc_groups_to_admin(current_department).map{|lg| lg.locations}.flatten
  end

  def check_data_object_admin_permission(obj)
    if (current_user.loc_groups_to_admin(current_department).map{|lg| lg.locations}.flatten & obj.locations).empty?
      flash[:notice] = "You do not have permission to administer this data object."
      redirect_to access_denied_path
      return false
    end
    return true
  end

end

