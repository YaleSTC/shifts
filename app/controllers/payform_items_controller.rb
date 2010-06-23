class PayformItemsController < ApplicationController
  layout 'payforms'
  helper 'payforms'

  def new
    @payform = Payform.find(params[:payform_id])
    return unless user_is_owner_or_admin_of(@payform, @payform.department)
    @payform_item = PayformItem.new
    layout_check
  end

  def create
    get_hours
    @payform_item = PayformItem.new(params[:payform_item])
  if params[:payform_id]
      @payform = Payform.find(params[:payform_id])
  else
    @payform = @payform_item.parent.payform
  end
    return unless user_is_owner_or_admin_of(@payform, @payform.department)
    @payform_item.payform = @payform
    @payform.submitted = nil
    if @payform_item.save and @payform.save
      flash[:notice] = "Successfully created payform item."
      redirect_to @payform
    else
      render :action => 'new'
    end
  end

  def edit
    @payform_item = PayformItem.find(params[:id])
    @payform = @payform_item.payform
    return unless user_is_owner_or_admin_of(@payform, @payform.department)
    layout_check
  end

  def update
    get_hours
    @payform_item = PayformItem.new(params[:payform_item])
    @payform_item.parent = PayformItem.find(params[:id])
    @payform_item.parent.reason = @payform_item.reason
    @payform_item.reason = nil
    @payform = @payform_item.payform = @payform_item.parent.payform
    @payform_item.parent.payform = nil  # this line caused headaches!
    @payform_item.source = current_user.name

    return unless user_is_owner_or_admin_of(@payform, @payform.department)

    begin
# unfortunately the only way I could get this to work was such that if there are
# errors in both (ie with the reason and something else), it'll  tell you about
# the reason, then, when you've fixed that, it'll tell you about the rest.
#      errors = []
      PayformItem.transaction do
        @payform_item.save(false)
        @payform_item.parent.save!
        @payform_item.save!
        @payform.submitted = nil
        @errors = "Failed to unsubmit payform" unless @payform.save
      end
      if @payform_item.user != current_user
        AppMailer.deliver_payform_item_change_notification(@payform_item.parent, @payform_item, @payform.department)
      end
      flash[:notice] = "Successfully edited payform item."
      redirect_to @payform_item.payform

    rescue Exception => e
      @payform = @payform_item.payform
      @payform_item = PayformItem.find(params[:id])
      @payform_item.add_errors(e)
      @payform_item.attributes = params[:payform_item]
      @payform_item.payform = @payform
      flash[:error].now = @errors.to_s if @errors
      render :action => 'edit'
    end
  end

  def delete
    @payform_item = PayformItem.find(params[:id])
    @payform = @payform_item.payform
    return unless user_is_owner_or_admin_of(@payform, @payform.department)
    layout_check
  end

  def destroy
    @payform_item = PayformItem.find(params[:id])
    @payform_item.reason = params[:payform_item][:reason]
    @payform = @payform_item.payform
    return unless user_is_owner_or_admin_of(@payform, @payform.department)
    @payform_item.active = false
    @payform_item.source = current_user.name

    begin
      PayformItem.transaction do
        @payform_item.save!
      end
      if @payform_item.payform.user != current_user  # just for testing; should be != instead
        AppMailer.deliver_payform_item_deletion_notification(@payform_item, @payform.department)
      end
      flash[:notice] = "Payform item deleted." if @payform_item.payform.submitted == false
      redirect_to @payform

    rescue
     @payform = @payform_item.payform
      if !@payform_item.payform.save
        flash.now[:error] = "Error unsubmitting payform. "
      else
        flash.now[:error] = @payform_item.errors.to_sentence
      end
      render :action => 'delete'
    end
  end

  protected

  def get_hours
    if params[:calculate_hours] == 'user_input'
      params[:payform_item][:hours] = params[:other][:hours].to_f + params[:other][:minutes].to_f/60
    else
      start_params = []
      end_params = []
      for num in (1..7)
        unless num == 6 #we skip seconds; meridian is stored in 7
          start_params << params[:time_input]["start(#{num}i)"].to_i
          end_params << params[:time_input]["end(#{num}i)"].to_i
        end
      end
      start_time = convert_to_time(start_params)
      end_time = convert_to_time(end_params)
      params[:payform_item][:hours] = (end_time-start_time) / 3600.0
    end
  end


  def convert_to_time(date_array)
    # 0 = year, 1 = month, 2 = day, 3 = hour, 4 = minute, 5 = meridiem(am/pm)
    if date_array[3] == 12 #if noon or midnight
      date_array[3] -= 12
    end
    if date_array[5] == -2 #if pm
      date_array[3] += 12
    end
    Time.utc(date_array[0], nil, nil, date_array[3], date_array[4])
  end

end

