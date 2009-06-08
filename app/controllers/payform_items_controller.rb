class PayformItemsController < ApplicationController
  def index
    @payform_items = PayformItem.all
  end
  
  def show
    @payform_item = PayformItem.find(params[:id])
  end
  
  def new
    @payform_item = PayformItem.new
  end
  
  def create
    @payform_item = PayformItem.new(params[:payform_item])
    if @payform_item.save
      flash[:notice] = "Successfully created payform item."
      redirect_to @payform_item
    else
      render :action => 'new'
    end
  end
  
  def edit
    @payform_item = PayformItem.find(params[:id])
  end
  
  def update
    @payform_item = PayformItem.find(params[:id])
    if @payform_item.update_attributes(params[:payform_item])
      flash[:notice] = "Successfully updated payform item."
      redirect_to @payform_item
    else
      render :action => 'edit'
    end
  end
  
  def destroy
    @payform_item = PayformItem.find(params[:id])
    @payform_item.destroy
    flash[:notice] = "Successfully destroyed payform item."
    redirect_to payform_items_url
  end
end
