class ReportsController < ApplicationController
  def index
    @reports = Report.all
  end

  def show
    @report = params[:id] ? Report.find(params[:id]) : Report.find_by_shift_id(params[:shift_id])
    @report_item = ReportItem.new
  end

  def new
    @report = Report.new
    #redirect_to :action => 'create', :method => :post
  end

  def create
    @report = Report.new(:shift_id => params[:shift_id], :arrived => Time.now)
    @report.shift.user.login
    # add a report item about logging in
    @report.report_items << ReportItem.new(:time => Time.now, :content => @report.shift.user.login+" logged in")
    if @report.save
      flash[:notice] = "Successfully created report."
      redirect_to @report
    else
      render :action => 'new'
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
      @report.report_items << ReportItem.new(:time => Time.now, :content => @report.shift.user.login+" logged out", :ip_address => request.remote_ip)
      @report.shift.update_attribute(:end, Time.now) unless @report.shift.scheduled?
    end
    if @report.update_attributes(params[:report])
      flash[:notice] = "Successfully submitted report."
      redirect_to @report
    else
      render :action => 'edit'
    end
  end

  def destroy
    @report = Report.find(params[:id])
    @report.destroy
    flash[:notice] = "Successfully destroyed report."
    redirect_to reports_url
  end
end
