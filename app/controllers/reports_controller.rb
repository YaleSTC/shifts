class ReportsController < ApplicationController
  #AJAX requests will be returned without layout
  layout proc{ |c| c.params[:format] == "js" ? false : "application" }

  def index
    @reports = Report.find(:all, :order => :arrived)
  end

  def show
    @report = params[:id] ? Report.find(params[:id]) : Report.find_by_shift_id(params[:shift_id])
    @report_item = ReportItem.new
  end

  def popup
    @report = params[:id] ? Report.find(params[:id]) : Report.find_by_shift_id(params[:shift_id])
    render :layout => false
  end

  def new
    #TODO: this doesn't work, because we can't redirect with post. bah.
    @report = Report.new
    #post_via_redirect :action => 'create'
  end

  def create
    @report = Report.new(:shift_id => params[:shift_id], :arrived => Time.now)
    # add a report item about logging in
    @report.report_items << ReportItem.new(:time => Time.now, :content => @report.shift.user.login+" logged in at "+request.remote_ip, :ip_address => request.remote_ip)
    if @report.user==current_user && @report.save
      redirect_to @report
    else
      flash[:notice] = "You can\'t sign into someone else's report!" unless @report.shift.user==current_user
      redirect_to shifts_path
    end
  end

  def edit
    @report = Report.find(params[:id])
  end

  def update
    @report = Report.find(params[:id])
    if (params[:sign_out])
      @report.departed = Time.now
      # add a report item about logging out
      @report.report_items << ReportItem.new(:time => Time.now, :content => @report.shift.user.login+" logged out from "+request.remote_ip, :ip_address => request.remote_ip)
      @report.shift.update_attribute(:end, Time.now) unless @report.shift.scheduled?
    end
    if @report.update_attributes(params[:report])
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
      redirect_to @report
    else
      render :action => 'edit'
    end
  end

  def destroy
    @report = Report.find(params[:id])
    @report.destroy
    #ArMailer.deliver()
    flash[:notice] = "Successfully destroyed report."
    redirect_to reports_url
  end
end
