class PayformItemSetsController < ApplicationController
  layout "payforms"
  
  before_filter :require_department_admin
  
  # Shouldn't this filter by department?
  def index
    @payform_item_sets = PayformItemSet.all
  end
  
  def show
    @payform_item_set = PayformItemSet.find(params[:id])
  end
  
  def new
    @payform_item_set = PayformItemSet.new
    @users_select = current_department.users.sort_by(&:last_name)
  end
  
  def create
    @payform_item_set = PayformItemSet.create(params[:payform_item_set])
    date = build_date_from_params(:date, params[:payform_item_set])
    params[:user_ids].each do |user_id| 
      unless user_id == ""

      payform_item = PayformItem.new(params[:payform_item_set])
      payform_item.payform = Payform.build(current_department, User.find(user_id), date)
      @payform_item_set.payform_items << payform_item
      end
    end
    if @payform_item_set.save
      flash[:notice] = "Successfully created payform item set."
      redirect_to @payform_item_set
    else
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
    @old_payform_items = @payform_item_set.payform_items 
    @old_users = @payform_item_set.users
    @new_users = (params[:user_ids] - [""]).collect {|id| User.find(id) }
    
    @delete_users = @old_users - @new_users
    @add_users = @new_users - @old_users
    
    date = build_date_from_params(:date, params[:payform_item_set])    

    begin 
      PayformItemSet.transaction do 
        
        @add_users.each do |user| 
          payform_item = PayformItem.new(params[:payform_item_set])
          payform_item.payform = Payform.build(current_department, user, date)
          @payform_item_set.payform_items << payform_item
        end
        
        @old_payform_items.each do |item| 
          if @delete_users.include?(item.user)
            item.active = false
            item.source = current_user.name 
            item.reason = "#{current_user.name} removed you from this group job."
            item.save!
          elsif !@add_users.include?(item.user)
            new_item = PayformItem.new(params[:payform_item_set])
            new_item.payform = Payform.build(current_department, item.user, date)
            new_item.source = current_user.name 
            new_item.parent = item 

            item.reason = "#{current_user.name} changed this group job."
            item.payform = nil 
            
            new_item.save(false)
            item.save! 
            new_item.save!
          end 
        end
        @payform_item_set.update_attributes!(params[:payform_item_set])
        
      end
  
      flash[:notice] = "Successfully updated payform item set."
      redirect_to @payform_item_set
    
    rescue Exception => e
      @users_select = current_department.users.sort_by(&:name)
      flash[:error] = e.to_s
      render :action => 'edit'
    end
  end
  
  def destroy
    @payform_item_set = PayformItemSet.find(params[:id])
    @payform_item_set.active = false 
    @payform_items = @payform_item_set.payform_items
    
    begin
      PayformItemSet.transaction do 

      @payform_items.each do |item|
        item.active = false
        item.source = current_user.name 
        item.reason = "#{current_user.name} deleted this group job."
        item.save!
      end
        @payform_item_set.save!
      end 

    flash[:notice] = "Successfully destroyed payform item set."
    redirect_to payform_item_sets_url
      
    rescue Exception => e
      @payform_item_set = PayformItemSet.find(params[:id])
      flash[:error] = e.to_s
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
