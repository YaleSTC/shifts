 class PayformItemSetsController < ApplicationController
layout "payforms"

  before_filter :require_department_admin
  
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
    @payform_item_set = PayformItemSet.create(params[:payform_item_set])
    params[:user_ids] ||= []
    date = build_date_from_params(:date, params[:payform_item_set])
    params[:user_ids].each do |user_id|
      payform_item = PayformItem.new(params[:payform_item_set])
      payform_item.payform = Payform.build(current_department, User.find(user_id), date)
      @payform_item_set.payform_items << payform_item
    end
    if @payform_item_set.save
      flash[:notice] = "Successfully created payform item set."
      redirect_to @payform_item_set
    else
      render :action => "new"
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
  
  private
  
  def build_date_from_params(field_name, params)
    Date.new(params["#{field_name.to_s}(1i)"].to_i, 
             params["#{field_name.to_s}(2i)"].to_i, 
             params["#{field_name.to_s}(3i)"].to_i)
  end

end
