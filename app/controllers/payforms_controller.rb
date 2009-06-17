class PayformsController < ApplicationController

  def index
    if current_user.is_admin_of?(current_department)
      @payforms =  current_department.payforms
    else
      @payforms =  current_department.payforms && current_user.payforms
    end
    @payforms.sort{|a,b| a.date <=> b.date}
  end

  def show
    @payform = Payform.find(params[:id])
    unless @payform && (@payform.user == current_user || current_user.is_admin_of?(current_department)) && @payform.department == current_department
      flash[:notice] = "Invalid payform"
      redirect_to payforms_path
    end
  end

  def go
    date = params[:date] ? params[:date].to_date : Date.today
    redirect_to Payform.build(current_department, current_user, date)
  end
  
  def prune
    @payforms = current_user.payforms & current_department.payforms
    @payforms.select{|p| p.payform_items.empty? }.map{|p| p.destroy }
    flash[:notice] = "Successfully pruned empty payforms."
    redirect_to payforms_path
  end
  
  def submit
    @payform = Payform.find(params[:id])
    @payform.submitted = Time.now
    if @payform.save
      flash[:notice] = "Successfully submitted payform."
    end
    redirect_to @payform
  end
  
  def approve
    @payform = Payform.find(params[:id])
    @payform.approved = Time.now
    @payform.approved_by = current_user
    if @payform.save
      flash[:notice] = "Successfully approved payform."
    end
    redirect_to @payform  
  end
  
  def print
    @payform = Payform.find(params[:id])
    # @payform.printed = Time.now
    if @payform.save
      flash[:notice] = "Printing is not implemented yet."
    end
    redirect_to @payform
  end

end

