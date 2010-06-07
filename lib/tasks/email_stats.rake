def shift_email(department)
  missed_shifts = Shift.between(1.day.ago.midnight, Time.now).select{|shift| shift.missed?}
  late_shifts  = Shift.between(1.day.ago.midnight, Time.now).select{|shift| shift.late?}
  left_early_shifts = Shift.between(1.day.ago.midnight, Time.now).select{|shift| shift.left_early?}  
  email = ArMailer.create_email_stats(missed_shifts, late_shifts, left_early_shifts, department)
  ArMailer.deliver(email)
end

 
desc "Sends out an e-mail to the admin whenever a user misses, is late to, or leaves a shift early"

task (:email_stats => :environment) do
  departments_that_want_admin_emailed = Department.all.select { |d| d.department_config.email_stats }
  for dept in departments_that_want_admin_emailed
    shift_email(dept)
  end
end

