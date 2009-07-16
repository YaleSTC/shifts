class PayformSetsController < ApplicationController
  helper :payforms
  layout "payforms"
  
  before_filter :require_department_admin
  
  def index
    @payform_sets = PayformSet.all
  end
  
  def show
    @payform_set = PayformSet.find(params[:id])
    respond_to do |show|
      show.html #show.html.erb
      show.pdf  #show.pdf.prawn
      show.csv do
        csv_string = FasterCSV.generate do |csv|
          csv << ["First Name", "Last Name", "Employee ID", "Start Date", "End Date", "Total Hours"]
          @payform_set.payforms.each do |payform|
            csv << [payform.user.first_name, payform.user.last_name, payform.user.employee_id, payform.start_date, payform.date, payform.hours]
          end
        end
        send_data csv_string, :type => 'text/csv; charset=iso-8859-1; header=present', :disposition => "attachment; filename=users.csv"
      end
    end
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
      flash[:notice] = "Error saving print job. Make sure approved payforms exist."
      redirect_to payforms_path
    end
  end
  
end
