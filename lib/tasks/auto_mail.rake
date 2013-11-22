namespace :email do
  
    def send_reminders(department)
      message = department.department_config.reminder_message
      @users = department.users.select {|u| if u.is_active?(department) then u.email end }
      users_reminded = []
      for user in @users
        if user.user_config.send_due_payform_email
        UserMailer.delay.due_payform_reminder(user, message, department)
        end
      end
      puts "#{users_reminded.length} users in the #{department.name} department "  +
           "have been reminded to submit their due payforms."
    end
  
    def send_warnings(department)
      message = department.department_config.warning_message
      start_date = (w = department.department_config.warning_weeks) ? Date.today - w.week : Date.today - 4.week
      @users = department.active_users.sort_by(&:name)
      users_warned = []
    
      for user in @users     
        #Payform.build(department, user, Date.today)
        unsubmitted_payforms = (Payform.all( :conditions => { :user_id => user.id, :department_id => department.id, :submitted => nil }, :order => 'date' ).select { |p| p if p.date >= start_date && p.date < Date.today }).compact
      
        unless unsubmitted_payforms.blank?
          weeklist = ""
          for payform in unsubmitted_payforms
            weeklist += payform.date.strftime("\t%b %d, %Y\n")
          end
          UserMailer.delay.late_payform_warning(user, message.gsub("@weeklist@", weeklist), department)
          users_warned << "#{user.name} (#{user.login}) <pre>#{user.email}</pre>"
        end
      end  # currently I am not doing anything with the list of users, it should be displayed somewhere
      puts "#{users_warned.length} users in the #{department.name} department "  +
           "have been warned to submit their late payforms."
    end

  #rake part
  desc "Send automatic reminders for due payforms"

  task :late_payform_warnings => :environment do
    departments_that_want_users_warned = Department.all.select { |d| d.department_config.auto_warn }
    for dept in departments_that_want_users_warned
      send_warnings(dept)
    end
  end

  desc "Send automatic warnings for late payforms"

  task :payform_reminders => :environment do
    departments_that_want_users_reminded = Department.all.select { |d| d.department_config.auto_remind }
    for dept in departments_that_want_users_reminded
      send_reminders(dept)
    end
  end

end
