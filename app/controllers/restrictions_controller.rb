class RestrictionsController < ApplicationController
  def index
    @restrictions = Restriction.all
  end
  
  def show
    @restriction = Restriction.find(params[:id])
  end
  
  def new
    @restriction = Restriction.new
  end
  
  def create
    @restriction = Restriction.new(params[:restriction])
    if @restriction.save
      flash[:notice] = "Successfully created restriction."
      redirect_to @restriction
    else
      render :action => 'new'
    end
  end
  
  def edit
    @restriction = Restriction.find(params[:id])
  end
  
  def update
    @restriction = Restriction.find(params[:id])
    if @restriction.update_attributes(params[:restriction])
      flash[:notice] = "Successfully updated restriction."
      redirect_to @restriction
    else
      render :action => 'edit'
    end
  end
  
  def destroy
    @restriction = Restriction.find(params[:id])
    @restriction.destroy
    flash[:notice] = "Successfully destroyed restriction."
    redirect_to restrictions_url
  end
end
