class PayformItemSetsController < ApplicationController
  def index
    @payform_item_sets = PayformItemSet.all
  end
  
  def show
    @payform_item_set = PayformItemSet.find(params[:id])
  end
  
  def new
    @payform_item_set = PayformItemSet.new
  end
  
  def create
    @payform_item_set = PayformItemSet.new(params[:payform_item_set])
    if @payform_item_set.save
      flash[:notice] = "Successfully created payform item set."
      redirect_to @payform_item_set
    else
      render :action => 'new'
    end
  end
  
  def edit
    @payform_item_set = PayformItemSet.find(params[:id])
  end
  
  def update
    @payform_item_set = PayformItemSet.find(params[:id])
    if @payform_item_set.update_attributes(params[:payform_item_set])
      flash[:notice] = "Successfully updated payform item set."
      redirect_to @payform_item_set
    else
      render :action => 'edit'
    end
  end
  
  def destroy
    @payform_item_set = PayformItemSet.find(params[:id])
    @payform_item_set.destroy
    flash[:notice] = "Successfully destroyed payform item set."
    redirect_to payform_item_sets_url
  end
end
