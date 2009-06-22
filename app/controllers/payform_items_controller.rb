class PayformItemsController < ApplicationController
  def new
    @payform = Payform.find(params[:payform_id])
    @payform_item = PayformItem.new
  end

  def create
    @payform_item = PayformItem.new(params[:payform_item])
    @payform = Payform.find(params[:payform_id])
    @payform_item.payform = @payform
    if @payform_item.save
      flash[:notice] = "Successfully created payform item."
      redirect_to @payform
    else
      render :action => 'new'
    end
  end

  def edit
    @payform_item = PayformItem.find(params[:id])
    @payform_item.payform_item_set = nil
  end

  def update
    @payform_item = PayformItem.find(params[:id])
    if @payform_item.update_attributes(params[:payform_item])
      flash[:notice] = "Successfully updated payform item."
      redirect_to @payform_item.payform
    else
      render :action => 'edit'
    end
  end

  def destroy
    @payform_item = PayformItem.find(params[:id])
    @payform = @payform_item.payform
    @payform_item.destroy
    flash[:notice] = "Payform item deleted."
    redirect_to payform_path(@payform)
  end
end

