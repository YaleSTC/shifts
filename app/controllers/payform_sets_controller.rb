class PayformSetsController < ApplicationController
  
  def index
    @payform_sets = PayformSet.all
  end
  
  def show
    @payform_set = PayformSet.find(params[:id])
  end
  
  def create
    @payform_set = PayformSet.new
    @payform_set.department = current_department
    @payform_set.payforms = current_department.payforms.unprinted
    @payform_set.payforms.map {|p| p.printed = Time.now }
    if @payform_set.save
      flash[:notice] = "Successfully created payform set."
      redirect_to @payform_set
    else
      flash[:notice] = "Error saving print job."
      redirect_to payforms_path
    end
  end
  
end
