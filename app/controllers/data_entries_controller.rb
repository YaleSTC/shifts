class DataEntriesController < ApplicationController
  #Not yet secured
  
  before_filter :check_for_data_object
  
# Probably not needed
#  def index
#    @data_object = DataObject.find(params[:data_object_id])
#    @data_entries = DataEntry.find_all_by_data_object_id(params[:data_object_id])
#  end

# Probably not needed  
#  def show
#    @data_entry = DataEntry.find(params[:id])
#  end

# Necesssary  
  def new
    @data_entry = DataEntry.new
    @data_object = DataObject.find(params[:data_object_id])
    layout_check
  end
  
# Necessary
  def create
    @data_entry = DataEntry.new({:data_object_id => params[:data_object_id]})
    unless current_user.current_shift && current_user.current_shift.report.data_objects.include?(@data_entry.data_object)
      flash[:error] = "You are not signed into a shift."
      redirect_to(access_denied_path) and return false
    end
    @data_entry.write_content(params[:data_fields]) 
    if @data_entry.save
      flash[:notice] = "Successfully updated #{@data_entry.data_object.name}."
#      redirect_to shift report in some manner or way
      redirect_to data_object_path(params[:data_object_id]) #Maybe useful?  not removing yet -ben
    else
      render :action => 'new'
    end
  end
  
# Are we removing this feature?
#  def edit
#    @data_entry = DataEntry.find(params[:id])
#    @data_object = DataObject.find(params[:data_object_id])
#  end
#  
#  def update
#    @data_entry = DataEntry.find(params[:id])
#    if @data_entry.update_attributes(params[:data_entry])
#      flash[:notice] = "Successfully updated data entry."
#      redirect_to data_object_path(params[:data_object_id])
#    else
#      render :action => 'edit'
#    end
#  end

# Definitely not needed  
#  def destroy
#    @data_entry = DataEntry.find(params[:id])
#    @data_entry.destroy
#    flash[:notice] = "Successfully destroyed data entry."
#    redirect_to data_entries_url
#  end
  
  private
  
  def check_for_data_object
    unless params[:data_object_id]
      flash[:error] = "You must specify a data object before viewing associated \
                      data fields."
      redirect_to data_objects_path
    end
  end
end
