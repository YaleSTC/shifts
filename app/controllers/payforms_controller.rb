class PayformsController < ApplicationController
  before_filter :require_department_admin,  :except => [:index, :show, :go, :prune, :submit, :unsubmit]

  def index
    # raise params.to_yaml
    @start_date = interpret_start
    @end_date = interpret_end
    @payforms = narrow_down(current_user.is_admin_of?(current_department) ?
                            current_department.payforms :
                            current_department.payforms && current_user.payforms)
    @payforms = @payforms.select{|payform| payform.date >= @start_date && payform.date <= @end_date}
    @payforms = @payforms.sort_by{|payform| [payform.user.reverse_name, Date.today - payform.date]}
  end

  def show
    @payform = Payform.find(params[:id])
    flash[:error] = "Payform does not exist." unless @payform
    flash[:error] = "The payform (from #{@payform.department.name}) is not in this department (#{current_department.name})." unless @payform.department == current_department
    flash[:warning] = "This payform is for a current/future time period" if @payform.date > Date.today
    return unless user_is_owner_or_admin_of(@payform, @payform.department)
    if flash[:error]
      redirect_to payforms_path
    else
      respond_to do |show|
        show.html #show.html.erb
        show.pdf  #show.pdf.prawn
        show.csv do
          csv_string = FasterCSV.generate do |csv|
            csv << ["First Name", "Last Name", "Employee ID", "Payrate", "Start Date", "End Date", "Total Hours"]
            csv << [@payform.user.first_name, @payform.user.last_name, @payform.user.employee_id, @payform.payrate, @payform.start_date, @payform.date, @payform.hours]
          end
          send_data csv_string, :type => 'text/csv; charset=iso-8859-1; header=present', :disposition => "attachment; filename=users.csv"
        end
      end
    end
  end

  def go
    date = params[:date] ? params[:date].to_date : Date.today
    redirect_to Payform.build(current_department, current_user, date)
  end

  def prune
    @payforms = current_department.payforms
    @payforms &= current_user.payforms unless current_user.is_admin_of?(current_department)
    @payforms.select{|p| p.payform_items.empty? }.map{|p| p.destroy }
    flash[:notice] = "Successfully pruned empty payforms."
    redirect_to payforms_path
  end

  def submit
    @payform = Payform.find(params[:id])
    return unless user_is_owner_or_admin_of(@payform, @payform.department)
    @payform.submitted = Time.now
 
    if @payform.date > Date.today
      flash[:warning] = "You have submitted a payform that ends on a future date. Please unsubmit this payform if this was unintentional"
    end
 
    if @payform.save && @payform.hours > current_department.department_config.payform_time_limit
      flash[:notice] = "Successfully submitted payform, however, you have submitted more than the allowed #{current_department.department_config.payform_time_limit} hours this week."
    elsif @payform.save &&  @payform.hours <= current_department.department_config.payform_time_limit
      flash[:notice] = "Successfully submitted payform."
    end
    respond_to do |format|
      format.html {redirect_to @payform }
      format.js
    end
  end

  def unsubmit
    @payform = Payform.find(params[:id])
    return unless user_is_owner_or_admin_of(@payform, @payform.department)
    @payform.submitted = nil
    if @payform.save
      flash[:notice] = "Successfully unsubmitted payform."
    end
    redirect_to @payform
  end

  def approve
     @payform = Payform.find(params[:id])
     @payform.approved = Time.now
     @payform.approved_by = current_user
     if @payform.save
       flash[:notice] = "Successfully approved payform. #{Payform.unapproved.select{|p| p.date == @payform.date}.size} payform(s) left for the week of #{@payform.date.strftime("%b %d %Y")}."
     end
     redirect_to_next_payform
   end

   def skip
     @payform = Payform.find(params[:id]) 
     @payform.skipped = Time.now
     if @payform.save
       flash[:notice] = "Sucessfully skipped payform. #{Payform.unapproved.select{|p| p.date == @payform.date}.size} payform(s) left for the week of #{@payform.date.strftime("%b %d %Y")}."
     end
     redirect_to_next_payform
   end
   
   def unskip
     @payform = Payform.find(params[:id]) 
     @payform.skipped = nil
     if @payform.save
       flash[:notice] = "Sucessfully unskipped payform."
     end
     redirect_to_next_payform
   end


  def unapprove
    @payform = Payform.find(params[:id])
    @payform.approved = nil
    @payform.approved_by = nil
    if @payform.save
      flash[:notice] = "Successfully unapproved payform."
    end
    redirect_to @payform
  end


  def print
    @payform = Payform.find(params[:id])
    @payform.printed = Time.now
    @payform_set = PayformSet.new
    @payform_set.department = @payform.department
    @payform_set.payforms << @payform
    if @payform_set.save && @payform.save
      flash[:notice] = "Successfully created payform set."
      redirect_to @payform_set
    else
      flash[:notice] = "Error saving print job. Make sure approved payforms exist."
      redirect_to @payform
    end
  end

  def search
    users = current_department.active_users
    start_date = interpret_start
    end_date = interpret_end
    #filter results if we are searching
    if params[:search]
      search_result = []
      users.each do |user|
        if user.login.downcase.include?(params[:search].downcase) or user.name.downcase.include?(params[:search].downcase)
          search_result << user
        end
      end
      users = search_result.sort_by(&:last_name)
    end
    @payforms = []
    for user in users
      @payforms += narrow_down(user.payforms)
    end
    @payforms = @payforms.select{|payform| payform.date >= start_date && payform.date <= end_date}
  end

  def email_reminders
    if !params[:id] or params[:id].to_i != @department.id
      redirect_to :email_reminders and return
##originally we also had :id => @department.id  ~Casey
    end
    @default_reminder_msg = current_department.department_config.reminder_message
    @default_warning_msg = current_department.department_config.warning_message
    @default_warn_start_date = 8.weeks.ago
  end

  def send_reminders
    message = params[:post]["body"]
    @users = current_department.users.select {|u| if u.is_active?(current_department) then u.email end }
    admin_user = current_user
    users_reminded = []
    for user in @users
      UserMailer.delay.due_payform_reminder(user, message, current_department)
      users_reminded << "#{user.name} (#{user.login})"
    end
    flash[:notice] = "E-mail reminders sent to the following: #{users_reminded.to_sentence}"
    redirect_to :email_reminders
  end

  def send_warnings
    message = params[:post]["body"]
    start_date = Date.parse(params[:post]["date"])
    @department = current_department
    @users = current_department.active_users.sort_by(&:name)
    users_warned = []
    @admin_user = current_user
    for user in @users
      Payform.build(@department, user, Date.today)
      unsubmitted_payforms = (Payform.all( :conditions => { :user_id => user.id, :department_id => @department.id, :submitted => nil }, :order => 'date' ).select { |p| p if p.date >= start_date && p.date < Date.today }).compact

      unless unsubmitted_payforms.blank?
        weeklist = ""
        for payform in unsubmitted_payforms
          weeklist += payform.date.strftime("\t%b %d, %Y\n")
        end
        UserMailer.delay.late_payform_warning(user, message.gsub("@weeklist@", weeklist), @department)
        users_warned << "#{user.name} (#{user.login}) <pre>#{email.encoded}</pre>"
      end
    end
    flash[:notice] = "E-mail warnings sent to the following: <br/><br/>#{users_warned.join}"
    redirect_to :email_reminders
  end

  protected

  def narrow_down(payforms)
    if ( !params[:unsubmitted] and !params[:submitted] and !params[:approved] and !params[:skipped] and !params[:printed]  )
      params[:unsubmitted] = params[:submitted] = params[:approved] = true
    end
    scope = []
    if params[:unsubmitted]
      scope += payforms.unsubmitted
    end
    if params[:skipped]
      scope += payforms.skipped.unapproved
    end  
    if params[:submitted]
      scope += payforms.unapproved
    end
    if params[:approved]
      scope += payforms.unprinted
    end
    if params[:printed]
      scope += payforms.printed
    end
    scope
  end
  

  
  private
  
  def interpret_start
    if params[:payform]
      return Date.civil(params[:payform][:"start_date(1i)"].to_i,params[:payform][:"start_date(2i)"].to_i,params[:payform][:"start_date(3i)"].to_i)
    elsif params[:start_date]
      return params[:start_date].to_date
    else
      return 1.week.ago.to_date
    end
  end
  
  def interpret_end
    if params[:payform]
      return Date.civil(params[:payform][:"end_date(1i)"].to_i,params[:payform][:"end_date(2i)"].to_i,params[:payform][:"end_date(3i)"].to_i)
    elsif params[:end_date]
      return params[:end_date].to_date
    else
      return Date.today.to_date
    end
  end

  def redirect_to_next_payform
    if Payform.unapproved.unskipped.any?
      payform_source = Payform.unapproved.unskipped
    else
      payform_source = Payform.unapproved
      flash[:warning] = "Note: You are viewing a skipped payform" if payform_source.any?
    end
    if payform_source.any?
      redirect_to payform_source.sort_by(&:date).last and return
    else
      redirect_to :action => "index" and return
    end
  end


end

