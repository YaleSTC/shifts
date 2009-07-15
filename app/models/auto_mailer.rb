class AutoMailer < ActiveRecord::Base

  departments_that_want_users_warned = Department.all.select { |d| d.auto_warn }
  departments_that_want_users_reminded = Department.all.select { |d| d.auto_remind }
  
  for department in departments_that_want_users_reminded
    #
  end

  for dept in departments_that_want_users_warned
    #
  end
  
  def send_reminders(department)
    message = department.department_config.reminder_message
    @users = department.users.select {|u| if u.is_active?(department) then u.email end }
    admin_user = User.find_by_login("kaa43")  # should be changed to the default admin or whatever
    users_reminded = []
    for user in @users
      ArMailer.deliver(ArMailer.create_due_payform_reminder(admin_user, user, message))
      users_reminded << "#{user.name} (#{user.login})"
    end
  end
  
  def send_warnings(department)
    message = department.department_config.warning_message
    start_date = Date.parse(params[:post]["date"])
    @department = current_department
    @users = @department.users.sort_by(&:name)
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
        email = ArMailer.create_late_payform_warning(@admin_user, user, message.gsub("@weeklist@", weeklist))
        ArMailer.deliver(email)
        users_warned << "#{user.name} (#{user.login}) <pre>#{email.encoded}</pre>"
      end
    end
    redirect_with_flash "E-mail warnings sent to the following: <br/><br/>#{users_warned.join}", :action => :email_reminders, :id => @department.id
  end
end
