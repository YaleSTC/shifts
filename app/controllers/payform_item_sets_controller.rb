class PayformItemSetsController < ApplicationController
  layout "payforms"
  
  before_filter :require_department_admin
  
  # Shouldn't this filter by department?
  def index
    @payform_item_sets = PayformItemSet.all
  end
  
  def show
    @payform_item_set = PayformItemSet.find(params[:id])
    @payform_items = @payform_item_set.payform_items.select{|p| p.payform_id}
  end
  
  def new
    @payform_item_set = PayformItemSet.new
    @users_select = current_department.active_users.sort_by(&:last_name)
  end
  
  def create
    params[:user_ids].delete("")
    @payform_item_set = PayformItemSet.new(params[:payform_item_set])
    date = build_date_from_params(:date, params[:payform_item_set])
    
    begin
      PayformItemSet.transaction do
        @payform_items = []
      
        users = User.find(params[:user_ids])
        users.each do |user| 
          payform_item = PayformItem.new(params[:payform_item_set])
          payform_item.payform = Payform.build(current_department, user, date)
          @payform_items << payform_item
        end
      
        if @payform_item_set.save and @payform_item_set.payform_items << @payform_items
          flash[:notice] = "Successfully created payform item set."
          redirect_to @payform_item_set   
        else
          flash[:error] = @payform_item_set.errors.full_messages.to_sentence
          @users_select = current_department.users.sort_by(&:name)
          render :action => "new"
        end 
      end
    rescue Exception => e
      flash[:error] = e.message
      @users_select = current_department.users.sort_by(&:name)
      render :action => "new"
    end
  end
  
  def edit
    @payform_item_set = PayformItemSet.find(params[:id])
    @users_select = current_department.users.sort_by(&:name)
  end
  
  def update
    @payform_item_set = PayformItemSet.find(params[:id])
    params[:user_ids].delete("")
    date = build_date_from_params(:date, params[:payform_item_set])
    @new_users = params[:user_ids].collect {|id| User.find(id) }
    @old_users = @payform_item_set.users
    @old_payform_items = @payform_item_set.payform_items.dup # .dup is crucial here!
                                                             # otherwise the loop below
                                                             # will go totally bonkers
   
    @delete_users = @old_users - @new_users
    @add_users = @new_users - @old_users
    
    begin 
      PayformItemSet.transaction do
        @old_payform_items.each do |old_payform_item|
          if @delete_users.include?(old_payform_item.user) #get rid of it
            old_payform_item.active = false
            old_payform_item.source = current_user.name 
            old_payform_item.reason = "#{current_user.name} removed you from this group job."
            old_payform_item.save!
            @payform_item_set.payform_items.delete(old_payform_item)
          else #update with new values
            new_item = PayformItem.new(params[:payform_item_set])
            new_item.payform = Payform.build(current_department, old_payform_item.user, date)
            new_item.source = current_user.name 
            new_item.parent = old_payform_item 

            old_payform_item.reason = "#{current_user.name} changed this group job."
            old_payform_item.payform = nil 
      
            new_item.save(false)
            old_payform_item.save! 
            new_item.save!
            @payform_item_set.payform_items.delete(old_payform_item)
            @payform_item_set.payform_items << new_item
          end
        end
  
        @add_users.each do |user| 
          payform_item = PayformItem.new(params[:payform_item_set])
          payform_item.payform = Payform.build(current_department, user, date)
          @payform_item_set.payform_items << payform_item
        end
        
        if @payform_item_set.update_attributes(params[:payform_item_set])
          flash[:notice] = "Successfully updated payform item set."
          redirect_to @payform_item_set   
        else
          flash[:error] = @payform_item_set.errors.full_messages.to_sentence
          @users_select = current_department.users.sort_by(&:name)
          render :action => "edit"
        end
      end    
    rescue Exception => e
      flash[:error] = e.message
      @users_select = current_department.users.sort_by(&:name)
      render :action => "edit"
    end
  end
  
  def destroy
    @payform_item_set = PayformItemSet.find(params[:id])
    @payform_item_set.active = false 
    @payform_items = @payform_item_set.payform_items
    
    begin
      PayformItemSet.transaction do 
        PayformItem.transaction do 

          @payform_items.each do |item|
            item.active = false
            item.source = current_user.name 
            item.reason = "#{current_user.name} deleted this group job."
            item.save!
          end

          @payform_item_set.save
      
          flash[:notice] = "Successfully destroyed payform item set."
          redirect_to payform_item_sets_url     
        end 
      end  
    rescue Exception => e
      @payform_item_set = PayformItemSet.find(params[:id])
      flash[:error] = e.message
      redirect_to payform_item_set_path(@payform_item_set)      
    end
  end
  
  private
  
  def build_date_from_params(field_name, params)
    Date.new(params["#{field_name.to_s}(1i)"].to_i, 
             params["#{field_name.to_s}(2i)"].to_i, 
             params["#{field_name.to_s}(3i)"].to_i)
  end

end
