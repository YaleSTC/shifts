class DataFieldsController < ApplicationController
  before_filter :require_department_admin
    before_filter :check_for_data_type, :except => :update_form
  
  def index
    @data_fields = DataField.find_all_by_data_type_id(params[:data_type_id])
  end
  
  def show
    @data_field = DataField.find(params[:id])
  end
  
  def new
    @data_field = DataField.new
  end
  
  def create
    @data_field = DataField.new(params[:data_field])
    @data_field.data_type_id = params[:data_type_id]
    if @data_field.save
      flash[:notice] = "Successfully created data field."
      redirect_to (params[:add_another] ? new_data_type_data_field_path(params[:data_type_id]) : (data_type_path(params[:data_type_id]) ))
    else
      render :action => 'new'
    end
  end
  
  def edit
    @data_field = DataField.find(params[:id])
  end
  
  def update
    @data_field = DataField.find(params[:id])
    if @data_field.update_attributes(params[:data_field])
      flash[:notice] = "Successfully updated data field."
      redirect_to (params[:add_another] ? new_data_type_data_field_path(params[:data_type_id]) : data_type_path(params[:data_type_id]))
    else
      render :action => 'edit'
    end
  end
  
  def destroy
    @data_field = DataField.find(params[:id])
    @data_type = @data_field.data_type
    @data_field.active = false
    @data_field.save
    flash[:notice] = "Successfully destroyed data field."
    redirect_to data_type_path(@data_type)
  end
  
  #For ajax only -ben
  def update_form(data_field_id = nil)
    @data_field = DataField.find(data_field_id) if data_field_id
    @display_type = params[:display_type] ? params[:display_type] : @data_field.display_type
    respond_to do |format|
      format.js
    end
  end
    
  private
  
  # Intercept and redirect if no data type id provided
  def check_for_data_type
    unless params[:data_type_id]
      flash[:error] = "You must specify a data type before viewing associated
                      data fields."
      redirect_to data_types_path
    end
  end
  
end
