class PayformSetsController < ApplicationController
  helper :payforms
  layout "payforms"

  before_filter :require_department_admin

  def index
    @payform_sets = PayformSet.all
  end

  def show
    @payform_set = PayformSet.find(params[:id])
    payform_items = @payform_set.payforms.map(&:payform_items).flatten
    @grouped_items = payform_items.group_by{|pi| pi.category.name}

    respond_to do |show|
      show.html #show.html.erb
      show.pdf  #show.pdf.prawn
      show.csv {render :text => @payform_set.payforms.export_payform}
      #show.xls {render :file => @payform_set.payforms.export_payform({:col_sep => "\t"})}
    end
  end

  def create
    @payform_set = PayformSet.new
    @payform_set.department = current_department
    @payform_set.payforms = current_department.payforms.unarchived
    @payform_set.payforms.map {|p| p.archived = Time.now }
    if @payform_set.save
      flash[:notice] = "Successfully created payform set."
      redirect_to @payform_set
    else
      flash[:notice] = "Error saving print job. Make sure approved payforms exist."
      redirect_to payforms_path
    end
  end

end
