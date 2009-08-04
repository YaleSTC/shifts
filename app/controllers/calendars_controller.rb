class CalendarsController < ApplicationController
  def index
    @calendars = Calendar.all
  end
  
  def show
    @calendar = Calendar.find(params[:id])
  end
  
  def new
    @calendar = Calendar.new
  end
  
  def create
    @calendar = Calendar.new(params[:calendar])
    if @calendar.save
      flash[:notice] = "Successfully created calendar."
      redirect_to @calendar
    else
      render :action => 'new'
    end
  end
  
  def edit
    @calendar = Calendar.find(params[:id])
  end
  
  def update
    @calendar = Calendar.find(params[:id])
    if @calendar.update_attributes(params[:calendar])
      flash[:notice] = "Successfully updated calendar."
      redirect_to @calendar
    else
      render :action => 'edit'
    end
  end
  
  def destroy
    @calendar = Calendar.find(params[:id])
    @calendar.destroy
    flash[:notice] = "Successfully destroyed calendar."
    redirect_to calendars_url
  end
end
