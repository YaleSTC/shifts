class AutoMailer < ActiveRecord::Base

  departments_that_want_users_warned = Department.all.select { |d| d.auto_warn }
  departments_that_want_users_reminded = Department.all.select { |d| d.auto_remind }
  
  for department in departments_that_want_users_reminded
    send_reminders(department)
  end

  for dept in departments_that_want_users_warned
    send_warnings(department)
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
    puts "#{users_reminded.length} users in the #{department.name} department "  +
         "have been reminded to submit their due payforms."
  end
  
  def send_warnings(department)
    message = department.department_config.warning_message
    start_date = (w = department.department_config.warning_weeks) ? w.weeks.ago : 8.weeks.ago
    @users = department.users.sort_by(&:name)
    users_warned = []
    @admin_user = User.find_by_login("kaa43")
    for user in @users     
      #Payform.build(department, user, Date.today)
      unsubmitted_payforms = (Payform.all( :conditions => { :user_id => user.id, :department_id => department.id, :submitted => nil }, :order => 'date' ).select { |p| p if p.date >= start_date && p.date < 1.week.ago }).compact
      
      unless unsubmitted_payforms.blank?
        weeklist = ""
        for payform in unsubmitted_payforms
          weeklist += payform.date.strftime("\t%b %d, %Y\n")
        end
        email = ArMailer.create_late_payform_warning(@admin_user, user, message.gsub("@weeklist@", weeklist))
        ArMailer.deliver(email)
        users_warned << "#{user.name} (#{user.login}) <pre>#{email.encoded}</pre>"
      end
    end  # currently I am not doing anything with the list of users, it should be displayed somewhere
    puts "#{users_reminded.length} users in the #{department.name} department "  +
         "have been warned to submit their late payforms."
  end
end
