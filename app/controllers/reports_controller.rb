class ReportsController < ApplicationController
  #AJAX requests will be returned without layout
  layout proc{ |c| c.params[:format] == "js" ? false : "reports" }

  def show
    @report = params[:id] ? Report.find(params[:id]) : Report.find_by_shift_id(params[:shift_id])
    return unless require_department_membership(@report.shift.department)
    @report_item = ReportItem.new
  end

  def popup
    @report = params[:id] ? Report.find(params[:id]) : Report.find_by_shift_id(params[:shift_id])
    return unless require_owner(@report.shift)
    render :layout => false
  end

  def create
    @report = Report.new(:shift_id => params[:shift_id], :arrived => Time.now)
    @report.report_items << ReportItem.new(:time => Time.now, :content => "#{@report.shift.user.login} logged in at #{request.remote_ip}", :ip_address => request.remote_ip)
    if @report.user==current_user && @report.save && !current_user.current_shift
      a = @report.shift
      a.signed_in = true
      a.save
      redirect_to @report
    else
      if current_user.current_shift
        flash[:notice] = "You can't sign into two shifts at the same time!"
      else
        flash[:notice] = "You can't sign into someone else's report!" unless @report.shift.user==current_user
      end
      redirect_to shifts_path
    end
  end

  def edit
    @report = Report.find(params[:id])
    return unless require_owner_or_dept_admin(@report.shift, @report.shift.department)
  end

  def update
    @report = Report.find(params[:id])
    return unless require_owner_or_dept_admin(@report.shift, @report.shift.department)
    if (params[:sign_out])
      @report.departed = Time.now
      @report.report_items << ReportItem.new(:time => Time.now, :content => "#{current_user.login} logged out from #{request.remote_ip}", :ip_address => request.remote_ip)
      @report.shift.update_attribute(:end, Time.now) unless @report.shift.scheduled?
    end
    if @report.update_attributes(params[:report]) && @report.user == current_user && @report.shift.update_attribute(:signed_in, false)
      @payform_item=PayformItem.new("hours" => @report.duration,
                                    "category"=>Category.find_by_name("Shifts"),
                                    "payform"=>Payform.build(@report.shift.location.loc_group.department, @report.user, Time.now),
                                    "date"=>Date.today,
                                    "description"=> @report.short_description,
                                    "source_url" => shift_report(@report.shift))
      AppMailer.deliver_shift_report(@report.shift, @report, @report.shift.department)
      if @payform_item.save
        flash[:notice] = "Successfully submitted report and updated payform."
      else
        flash[:notice] = "Successfully submitted report, but payform did not update. Please manually add the job to your payform."
      end
      respond_to do |format|
        format.html {redirect_to dashboard_path}
        format.js
      end
    else
      flash[:notice] = "Report not submitted.  You may not be the owner of this report."
      render :action => 'edit'
    end
  end

# Do we want this action? -ben
#  def destroy
#    @report = Report.find(params[:id])
#    @report.destroy
#    #ArMailer.deliver()
#    flash[:notice] = "Successfully destroyed report."
#    redirect_to reports_url
#  end
end

