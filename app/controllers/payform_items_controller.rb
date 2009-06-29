class PayformItemsController < ApplicationController
  layout 'payforms'
  
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
  end

  def update
    @payform_item = PayformItem.new(params[:payform_item])
    @payform_item.payform_item = PayformItem.find(params[:id])
    @payform_item.payform_item.payform_item_set = nil
    @payform_item.payform = @payform_item.payform_item.payform
    @payform_item.payform_item.payform = nil
    @payform_item.payform_item.active = false
    @payform_item.payform_item.reason = params[:payform_item][:reason]
    errors = []
    if !@payform_item.payform_item.save
      errors << "Failed to update the old payform item"
    end
    if !@payform_item.save
      errors << "Failed to create a new payform item"
    end
    if errors.length == 0
      flash[:notice] = "Successfully edited payform item."
      redirect_to @payform_item.payform
    else
      flash[:error] =  "Error: "+errors*"<br/>" 
      render :action => 'edit'
    end
  end

  def destroy
    @payform_item = PayformItem.find(params[:id])
    @payform = @payform_item.payform
    @payform_item.destroy
    flash[:notice] = "Payform item deleted." # send misleading message to user :)
    redirect_to payform_path(@payform)
  end
end

