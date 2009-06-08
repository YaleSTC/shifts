class CagtegoriesController < ApplicationController
  def index
    @cagtegories = Cagtegory.all
  end
  
  def show
    @cagtegory = Cagtegory.find(params[:id])
  end
  
  def new
    @cagtegory = Cagtegory.new
  end
  
  def create
    @cagtegory = Cagtegory.new(params[:cagtegory])
    if @cagtegory.save
      flash[:notice] = "Successfully created cagtegory."
      redirect_to @cagtegory
    else
      render :action => 'new'
    end
  end
  
  def edit
    @cagtegory = Cagtegory.find(params[:id])
  end
  
  def update
    @cagtegory = Cagtegory.find(params[:id])
    if @cagtegory.update_attributes(params[:cagtegory])
      flash[:notice] = "Successfully updated cagtegory."
      redirect_to @cagtegory
    else
      render :action => 'edit'
    end
  end
  
  def destroy
    @cagtegory = Cagtegory.find(params[:id])
    @cagtegory.destroy
    flash[:notice] = "Successfully destroyed cagtegory."
    redirect_to cagtegories_url
  end
end
