class PayformSetsController < ApplicationController
  def index
    @payform_sets = PayformSet.all
  end
  
  def show
    @payform_set = PayformSet.find(params[:id])
  end
  
  def new
    @payform_set = PayformSet.new
  end
  
  def create
    @payform_set = PayformSet.new(params[:payform_set])
    if @payform_set.save
      flash[:notice] = "Successfully created payform set."
      redirect_to @payform_set
    else
      render :action => 'new'
    end
  end
  
  def edit
    @payform_set = PayformSet.find(params[:id])
  end
  
  def update
    @payform_set = PayformSet.find(params[:id])
    if @payform_set.update_attributes(params[:payform_set])
      flash[:notice] = "Successfully updated payform set."
      redirect_to @payform_set
    else
      render :action => 'edit'
    end
  end
  
  def destroy
    @payform_set = PayformSet.find(params[:id])
    @payform_set.destroy
    flash[:notice] = "Successfully destroyed payform set."
    redirect_to payform_sets_url
  end
end
