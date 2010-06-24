class ReportItemsController < ApplicationController
# Commented out all unnecessary actions -ben
#  def index
#    @report_items = ReportItem.all
#  end

#  def show
#    @report_item = ReportItem.find(params[:id])
#  end

#  def new
#    @report_item = ReportItem.new
#  end

  def create
    @report_item = ReportItem.new(params[:report_item])
    @report_item.time = Time.now
    @report_item.ip_address = request.remote_ip
    @report_item.report = params[:report_id] ? Report.find(params[:report_id]) : Shift.find(params[:shift_id]).report
    respond_to do |format|
      @report = Report.find(@report_item.report_id)
      if current_user==@report_item.user && @report_item.save
        @report.shift.stale_shifts_unsent = true
        @report.shift.save
        format.html {redirect_to @report}
        format.js
      else
        flash[:notice] = "You can't add things to someone else's report." if @report_item.user != current_user
        format.html {redirect_to @report}
        format.js {redirect_to @report}
      end
    end
  end

#shifts.reports isn't going to work b/c. location.shifts.report b/c .report works on one shift. location.shifts is an array 

  def for_location
    start_time = 3.hours.ago.utc    
    end_time = Time.now.utc
  
    @location = Location.find(params[:id]) 

    @report_items = ReportItem.find(:all, :conditions => ["time > ? AND time < ?", start_time, end_time]).select{|r| r.report.shift.location == @location}.sort_by{|r| r.time}.reverse
   
  end
# past 3 hours. Find all shifts that ended in that past one select those shifts then tkae all of their report items and then draw them in line items. More can't show that. So genearlize it end in the past x hours. If we take shifts that started of it. So what you want to t o.. Find MATCH 
#report_items.each do |report_item|
#block of code. 
#report_items.find(:cond time > sometime interface this way first so that it's flexibile and then move on. 

#start.time params[:start] ||= 3.hours.ago.utc
#start_time = param[:start] || 3.hours.ago.utc
#end_time = #param[:end_time] || time.now

#  def edit
#    @report_item = ReportItem.find(params[:id])
#  end

#  def update
#    @report_item = ReportItem.find(params[:id])
#    if @report_item.update_attributes(params[:report_item])
#      flash[:notice] = "Successfully updated report item."
#      redirect_to @report_item
#    else
#      render :action => 'edit'
#    end
#  end

#  def destroy
#    @report_item = ReportItem.find(params[:id])
#    @report_item.destroy
#    flash[:notice] = "Successfully destroyed report item."
#    redirect_to shift_report_report_items_url(@report_item.report.shift)
#  end
end

