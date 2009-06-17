class DataEntriesController < ApplicationController
  
  before_filter :check_for_data_object
  
  def index
    @data_entries = DataEntry.find_all_by_data_object_id(params[:data_object_id])
  end
  
  def show
    @data_entry = DataEntry.find(params[:id])
  end
  
  def new
    @data_entry = DataEntry.new
    @data_object = DataObject.find(params[:data_object_id])
  end
  
  def create
    @data_entry = DataEntry.new
    @data_entry.write_content(params[:data_fields]) 
    @data_entry.data_object_id = params[:data_object_id]
    if @data_entry.save
      flash[:notice] = "Successfully created data entry."
      redirect_to @data_entry
    else
      render :action => 'new'
    end
  end
  
  def edit
    @data_entry = DataEntry.find(params[:id])
  end
  
  def update
    @data_entry = DataEntry.find(params[:id])
    if @data_entry.update_attributes(params[:data_entry])
      flash[:notice] = "Successfully updated data entry."
      redirect_to @data_entry
    else
      render :action => 'edit'
    end
  end
  
  def destroy
    @data_entry = DataEntry.find(params[:id])
    @data_entry.destroy
    flash[:notice] = "Successfully destroyed data entry."
    redirect_to data_entries_url
  end
  
  private
  
  def check_for_data_object
    unless params[:data_object_id]
      flash[:error] = "You must specify a data object before viewing associated \
                      data fields."
      redirect_to data_objects_path
    end
  end
  
end
