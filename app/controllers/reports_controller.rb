class ReportsController < ApplicationController
  #AJAX requests will be returned without layout
  layout proc{ |c| c.params[:format] == "js" ? false : "reports" }

  def show
    @report = params[:id] ? Report.find(params[:id]) : Report.where(:shift_id == params[:shift_id]).first
    # @tasks = Task.in_location(@report.shift.location).active.after_now.delete_if{|t| t.kind == "Weekly" && t.day_in_week != @report.shift.start.strftime("%a")}
    tasks = Task.in_location(@report.shift.location).active.after_now
    # filters out daily and weekly tasks scheduled for a time later in the day
    tasks = tasks.delete_if{|t| t.kind != "Hourly" && Time.now.seconds_since_midnight < t.time_of_day.seconds_since_midnight}
    # filters out weekly tasks on the wrong day
    @tasks = tasks.delete_if{|t| t.kind == "Weekly" && t.day_in_week != @report.shift.start.strftime("%a") }
    return unless require_department_membership(@report.shift.department)
    @report_item = ReportItem.new
    @search_engine_name = current_department.department_config.search_engine_name
    @search_engine_url = current_department.department_config.search_engine_url
  end

  #Signing into a shift
  def create
    shift = Shift.find(params[:shift_id])
    if shift.start > 1.day.from_now
      flash[:error] = "You can't sign into a shift too far in advance"
      redirect_to dashboard_path and return
    end

    @report = Report.new(:shift_id => params[:shift_id], :arrived => Time.now)

    if current_user.current_shift || current_user.punch_clock
      flash[:error] = "You are already signed into a shift or punch clock."
    elsif @report.user!=current_user
      flash[:error] = "You can't sign into someone else's report."
    else
      @report.save
      @report.report_items << ReportItem.new(:time => Time.now, :content => "#{current_user.name} (#{current_user.login}) logged in from #{request.remote_ip}", :ip_address => request.remote_ip)
      a = @report.shift
      a.signed_in = true
      a.save(false) #ignore validations because this is an existing shift or an unscheduled shift
      redirect_to @report and return
    end
    redirect_to shifts_path
  end

  def edit
    @report = Report.find(params[:id])
    return unless user_is_owner_or_admin_of(@report.shift, @report.shift.department)
  end


  #periodically call remote function to update reports dynamically
  def update_reports
     @report = current_user.current_shift.report
     respond_to do |format|
       format.js
     end
  end

  # TODO: refactor into a model method on Report
  #Submitting a shift
  def update
    @report = Report.find(params[:id])
    return unless user_is_owner_or_admin_of(@report.shift, @report.shift.department) || current_user.is_admin_of?(@report.shift.location)

    if (params[:sign_out] and @report.departed.nil?) #don't allow duplicate signout messages
      @report.departed = Time.now
      @report.report_items << ReportItem.new(:time => Time.now, :content => "#{current_user.name} (#{current_user.login}) logged out from #{request.remote_ip}", :ip_address => request.remote_ip)
      @report.shift.update_attribute(:end, Time.now) unless @report.shift.scheduled?
      # above method call isn't safe; it works because there are never sub requests on unscheduled shifts, but it'll cause validation problems
      # with shift.adjust_sub_requests if it ever does run. -ben
      @add_payform_item = true;
    end

    if @report.update_attributes(params[:report]) && @report.shift.update_attribute(:signed_in, false)
      if (@add_payform_item) #don't allow duplicate payform items for a shift
        @payform_item=PayformItem.new("hours" => @report.duration,
                                      "category"=>(@report.shift.location.category || current_department.department_config.default_category),
                                      "payform"=>Payform.build(@report.shift.location.loc_group.department, @report.user, Time.now),
                                      "date"=>Date.today,
                                      "description"=> @report.short_description,
                                      "source_url" => shift_report_path(@report.shift))
        AppMailer.deliver_shift_report(@report.shift, @report, @report.shift.department)
        if @payform_item.save
          flash[:notice] = "Successfully submitted report and updated payform."
        else
          flash[:notice] = "Successfully submitted report, but payform did not update. Please manually add the job to your payform."
        end
      else
        flash[:error] = "That report has already been submitted."
      end
      respond_to do |format|
        format.html {redirect_to dashboard_path}
        format.js
      end
    else
      flash[:notice] = "Report not submitted.  You may not be the owner of this report."
      render :action => 'show'
    end
  end


  def custom_search
    @key_word = params[:search]
    @search_engine_url = current_department.department_config.search_engine_url
    @search_url = @search_engine_url.concat(@key_word)
    respond_to do |format|
      format.js
      format.html{}
    end
  end



# Do we want this action? -ben
#  def destroy
#    @report = Report.find(params[:id])
 #   @report.destroy
  #  #ArMailer.deliver()
   # flash[:notice] = "Successfully destroyed report."
    #redirect_to reports_url
#  end
end

