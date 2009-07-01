class PayformItemsController < ApplicationController
  layout 'payforms'
  helper 'payforms'
  
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
    @payform = @payform_item.payform
  end

  def update
    @payform_item = PayformItem.new(params[:payform_item])
    @payform_item.payform_item = PayformItem.find(params[:id])
    @payform = @payform_item.payform_item.payform
    @payform_item.payform_item.payform_item_set = nil
    @payform_item.payform = @payform_item.payform_item.payform
    @payform_item.payform_item.payform = nil
    @payform_item.payform_item.active = false
    @payform_item.payform_item.reason = params[:payform_item][:reason]
    @payform_item.source = current_user.name
    @payform_item.user_id = @payform_item.payform_item.user_id  # must take out at some point
    errors = []
    if !@payform_item.payform_item.save
      errors << "Failed to update the old payform item"
    end
    if !@payform_item.save
      errors << "Failed to create a new payform item"
    end
    if errors.length == 0
      if @payform_item.user_id == current_user.id  # just for testing; should be != instead
        AppMailer.deliver_payform_item_change_notification(@payform_item.payform_item, @payform_item)
      end
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
    @payform_item.active = false
    @payform_item.source = current_user.name
    if @payform_item.user_id == current_user.id  # just for testing; should be != instead
      AppMailer.deliver_payform_item_change_notification(@payform_item)
    end
    if @payform_item.save
      flash[:notice] = "Payform item deleted."
    else
      flash[:notice] = "Error deleting payform item."
    end
    redirect_to @payform
  end
end

