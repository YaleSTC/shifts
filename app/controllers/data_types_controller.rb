class DataTypesController < ApplicationController
  before_filter :require_department_admin

  def index
    @data_types = DataType.find_all_by_department_id(current_department)
  end
  
  def show
    @data_type = DataType.find(params[:id])
  end
  
  def new
    @data_type = DataType.new
    #@data_type.data_fields.build
  end
  
  def create
    @data_type = DataType.new({:department => current_department})
    @data_type.update_attributes(params[:data_type])
    if @data_type.save
      flash[:notice] = "Successfully created data type."
      redirect_to (@data_type.data_fields.empty? ? new_data_type_data_field_path(@data_type) : @data_type)
    else
      render :action => 'new'
    end
  end
  
  def edit
    @data_type = DataType.find(params[:id])
    #@data_type.data_fields.build if @data_type.data_fields.empty?
  end
  
  def update
    @data_type = DataType.find(params[:id])
    if @data_type.update_attributes(params[:data_type])
      flash[:notice] = "Successfully updated data type."
      redirect_to @data_type
    else
      render :action => 'edit'
    end
  end
  
  def destroy
    @data_type = DataType.find(params[:id])
    @data_type.destroy
    flash[:notice] = "Successfully destroyed data type."
    redirect_to data_types_url
  end
  
end
