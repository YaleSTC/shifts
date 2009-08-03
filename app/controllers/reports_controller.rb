class ReportsController < ApplicationController
  #AJAX requests will be returned without layout
  layout proc{ |c| c.params[:format] == "js" ? false : "application" }

# unsecured for now; are we getting rid of this action? -ben
# this should discriminate by department
#  def index
#    @reports = Report.find(:all, :order => :arrived)
#  end

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

# Do we need this action?  -ben
# uncommented for now -- it's the default redirect after creating a shift. -ryan
# When we clean the interface, then we can take it out -ben
 def new
   #TODO: this doesn't work, because we can't redirect with post. bah.
   @report = Report.new
   #post_via_redirect :action => 'create'
 end

# Already secured by @report.user == current_user -ben
  def create
    @report = Report.new(:shift_id => params[:shift_id], :arrived => Time.now)
    # add a report item about logging in
    @report.report_items << ReportItem.new(:time => Time.now, :content => "#{@report.shift.user.login} logged in at #{request.remote_ip}", :ip_address => request.remote_ip)
    if @report.user==current_user && @report.save && !current_user.current_shift
      current_shift = @report.shift
      current_shift.signed_in = true
      current_shift.save
      redirect_to @report
    else
      if current_user.current_shift
        flash[:notice] = "You can't sign into two shifts!"
      else
        flash[:notice] = "You can\'t sign into someone else's report!" unless @report.shift.user==current_user
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
      # add a report item about logging out
      @report.report_items << ReportItem.new(:time => Time.now, :content => "#{current_user.login} logged out from #{request.remote_ip}", :ip_address => request.remote_ip)
      @report.shift.update_attribute(:end, Time.now) unless @report.shift.scheduled?
    end
    if @report.update_attributes(params[:report]) && @report.user == current_user
      @report.shift.signed_in = false
      @payform_item=PayformItem.new("hours"=>(@report.departed-@report.arrived)/3600,
                                    "category"=>Category.find_by_name("Shifts"),
                                    "payform"=>Payform.build(@report.shift.location.loc_group.department, @report.user, Time.now),
                                    "date"=>Date.today,
                                    "description"=>"Shift in the #{@report.shift.location.name}")
      if @payform_item.save
        flash[:notice] = "Successfully submitted report and updated payform."
      else
        flash[:notice] = "Successfully submitted report, but payform did not update. Please manually add the job to your payform."
      end
      respond_to do |format|
        format.html {redirect_to @report}
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

