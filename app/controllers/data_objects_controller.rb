class DataObjectsController < ApplicationController
  #User admin methods will need to be rewritten in move to other codebase
  
  def index
    if params[:data_type_id]
      @data_objects = DataObject.find_all_by_data_type_id(params[:data_type_id])
    elsif current_user.is_admin_of?(@department)
      @data_objects = DataObject.by_department(@department)
    elsif current_user.is_loc_group_admin?(@department)
      @data_objects = current_user.loc_groups_to_admin(@department).map{|lg| DataObject.by_location_group(lg)}.flatten
    else
      flash[:error] = "You do not have the permissions necessary to view any
                      data objects."
      redirect_to access_denied_path
    end
  end
  
  def show
    @data_object = DataObject.find(params[:id])
    @data_type = @data_object.data_type
  end
  
  def new
    @data_object = DataObject.new
    @data_type = DataType.find(params[:data_type_id])
  end
  
  def create
    #raise penguins
    @data_type = DataType.find(params[:data_object][:data_type_id])
    @data_object = DataObject.new(params[:data_object])
    @data_object.data_type_id = params[:data_object][:data_type_id]
    if @data_object.save
      flash[:notice] = "Successfully created data object."
      redirect_to :action => 'show', :id => @data_object.id
    else
      redirect_to params
    end
  end
  
  def edit
    @data_object = DataObject.find(params[:id])
    @data_type = @data_object.data_type
  end
  
  def update
    @data_object = DataObject.find(params[:id])
    if @data_object.update_attributes(params[:data_object])
      flash[:notice] = "Successfully updated data object."
      redirect_to @data_object
    else
      render :action => 'edit'
    end
  end
  
  def destroy
    @data_object = DataObject.find(params[:id])
    @data_object.destroy
    flash[:notice] = "Successfully destroyed data object."
    redirect_to data_objects_url
  end
end
