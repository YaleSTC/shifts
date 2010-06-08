class PayformsController < ApplicationController
  before_filter :require_department_admin,  :except => [:index, :show, :go, :prune, :submit, :unsubmit]

  def index
    @payforms = narrow_down(current_user.is_admin_of?(current_department) ?
                            current_department.payforms :
                            current_department.payforms && current_user.payforms)
    @payforms = @payforms.sort_by{|payform| payform.user.last_name}
  end

  def show
    @payform = Payform.find(params[:id])
    flash[:error] = "Payform does not exist." unless @payform
    flash[:error] = "The payform (from #{@payform.department.name}) is not in this department (#{current_department.name})." unless @payform.department == current_department
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
    if @payform.save
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
      flash[:notice] = "Successfully approved payform. #{Payform.unapproved.select{|p| p.date == @payform.date}.size} payform(s) left for this week."
    end
    @next_unapproved_payform = Payform.unapproved.select{|p| p.date == @payform.date}.sort_by(&:submitted).last
    @next_unapproved_payform ? (redirect_to @next_unapproved_payform and return) : (redirect_to :action => "index" and return)
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
  end

  def email_reminders
    if !params[:id] or params[:id].to_i != @department.id
      redirect_to :action => :email_reminders, :id => @department.id and return
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
      ArMailer.deliver(ArMailer.create_due_payform_reminder(admin_user, user, message))
      users_reminded << "#{user.name} (#{user.login})"
    end
    redirect_with_flash "E-mail reminders sent to the following: #{users_reminded.to_sentence}", :action => :email_reminders, :id => @department.id
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
        email = ArMailer.create_late_payform_warning(user, message.gsub("@weeklist@", weeklist), @department)
        ArMailer.deliver(email)
        users_warned << "#{user.name} (#{user.login}) <pre>#{email.encoded}</pre>"
      end
    end
    redirect_with_flash "E-mail warnings sent to the following: <br/><br/>#{users_warned.join}", :action => :email_reminders, :id => @department.id
  end

  protected

  def narrow_down(payforms)
    if ( !params[:unsubmitted] and !params[:submitted] and !params[:approved] and !params[:printed] )
      params[:unsubmitted] = params[:submitted] = params[:approved] = true
    end
    scope = []
    if params[:unsubmitted]
      scope += payforms.unsubmitted
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

end

