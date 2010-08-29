class PayformItemsController < ApplicationController
  layout 'payforms'
  helper 'payforms'

  def new
    @payform_item = PayformItem.new
    @payform_item.payform = Payform.find(params[:payform_id])
    #TODO: These return lines really only work with the ajax -- we should come up with a better solution.
    return unless user_is_owner_or_admin_of(@payform_item.payform, @payform_item.department)
    layout_check
  end

  def create
    set_payform_item_hours("payform_item")
    @payform_item = PayformItem.new(params[:payform_item])
    @payform_item.payform = Payform.find(params[:payform_id])
    return unless user_is_owner_or_admin_of(@payform_item.payform, @payform_item.department)
    @payform_item.source = current_user.name
    if @payform_item.save
      flash[:notice] = "Successfully created payform item."
      redirect_to @payform_item.payform
    else
      render :action => 'new'
    end
  end

  def edit
    @payform_item = PayformItem.find(params[:id])
    @payform_item.reason = nil #need a new reason each edit
    return unless user_is_owner_or_admin_of(@payform_item.payform, @payform_item.department)
    layout_check
  end

  def update
    set_payform_item_hours("payform_item")
    @payform_item = PayformItem.find(params[:id])
    return unless user_is_owner_or_admin_of(@payform_item.payform, @payform_item.department)
    @payform_item.attributes = params[:payform_item]
    @payform_item.updated_by = current_user.name
    if @payform_item.save
      if @payform_item.user != current_user
        #TODO: we need a new way of determining what has changed.
        #AppMailer.deliver_payform_item_change_notification(@payform_item.parent, @payform_item, @payform_item.payform.department)
      end
      flash[:notice] = "Successfully edited payform item."
      redirect_to @payform_item.payform
    else
      render :action => 'edit'
    end
  end

  def delete
    @payform_item = PayformItem.find(params[:id])
    @payform_item.reason = nil
    return unless user_is_owner_or_admin_of(@payform_item.payform, @payform_item.department)    
    layout_check
  end

  def destroy
    @payform_item = PayformItem.find(params[:id])
    return unless user_is_owner_or_admin_of(@payform_item.payform, @payform_item.department)    
    if @payform_item.update_attributes(:reason => params[:payform_item][:reason], :active => false, :updated_by => current_user.name)
      if @payform_item.payform.user != current_user
        AppMailer.deliver_payform_item_deletion_notification(@payform_item, @payform_item.department)
      end
      flash[:notice] = "Payform item deleted."
      redirect_to @payform_item.payform
    else
      render :action => 'delete'
    end
  end
  
end

