class PayformItemsController < ApplicationController
  layout 'payforms'
  helper 'payforms'
  
  def new
    @payform = Payform.find(params[:payform_id])
    @payform_item = PayformItem.new
    layout_check
  end

  def create
    get_hours
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
    layout_check
  end

  def update
    get_hours
    @payform_item = PayformItem.new(params[:payform_item])
    @payform_item.parent = PayformItem.find(params[:id])
    @payform_item.parent.reason = @payform_item.reason
    @payform_item.reason = nil
    @payform = @payform_item.payform = @payform_item.parent.payform
    @payform_item.parent.payform = nil  # this line caused headache!
    @payform_item.source = current_user.name
    errors = []
    if !@payform_item.parent.save
      errors << "Failed to update the old payform item"
    end
    if !@payform_item.save
      errors << "Failed to create a new payform item"
    end
    if errors.length == 0
      if @payform_item.user == current_user  # just for testing; should be != instead
        AppMailer.deliver_payform_item_change_notification(@payform_item.parent, @payform_item)
      end
        flash[:notice] = "Successfully edited payform item."
        redirect_to @payform_item.payform    
    else
      flash[:error] =  "Error: "+errors*"<br/>" 
      render :action => 'edit'
    end
  end
  
  def delete
    @payform_item = PayformItem.find(params[:id])
    @payform = @payform_item.payform
    layout_check
  end

  def destroy
    @payform_item = PayformItem.find(params[:id])
    @payform_item.reason = params[:payform_item][:reason]
    @payform = @payform_item.payform
    @payform_item.active = false
    @payform_item.source = current_user.name
    if @payform_item.payform.user == current_user  # just for testing; should be != instead
      AppMailer.deliver_payform_item_change_notification(@payform_item)
    end
    if @payform_item.save
      flash[:notice] = "Payform item deleted."
    else
      flash[:notice] = "Error deleting payform item."
    end
    redirect_to @payform
  end
  
  protected
  
  def get_hours
    if params[:calculate_hours] == 'user_input'
      params[:payform_item][:hours] = params[:other][:hours].to_f + params[:other][:minutes].to_f/60
    else
      start_params = []
      end_params = []
      for num in (1..6)
        start_params << params[:time_input]["start(#{num}i)"].to_i
        end_params << params[:time_input]["end(#{num}i)"].to_i
      end
      start_time = convert_to_time(start_params)
      end_time = convert_to_time(end_params)      
      params[:payform_item][:hours] = (end_time-start_time) / 3600.0
    end
  end
  
  
  def convert_to_time(date_array)
    # 0 = year, 1 = month, 2 = day, 3 = hour, 4 = minute, 5 = meridiem
    if date_array[3] == 12
      date_array[3] -= 12
    end
    if date_array[5] == 1
      date_array[3] += 12
    end
    Time.utc(date_array[0], nil, nil, date_array[3], date_array[4])
  end
end

