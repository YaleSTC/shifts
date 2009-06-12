class PayformsController < ApplicationController

  def index
    @payforms = current_user.payforms & current_department.payforms
  end

  def show
    @payform = Payform.find(params[:id])
    unless @payform && @payform.user == current_user && @payform.department == current_department
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

end

