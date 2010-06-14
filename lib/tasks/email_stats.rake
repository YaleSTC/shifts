def shift_email(department)
  
  shifts_to_email = []
  shifts_to_email = Shift.in_department(department).active.between(7.days.ago.midnight, Time.now).stats_sent
    
  missed_shifts = []
  late_shifts = []
  left_early_shifts = []
    
  for shift in shifts_to_email
    missed_shifts = shifts_to_email.missed
    late_shifts = shifts_to_email.late
    left_early_shifts = shifts_to_email.left_early
  end
  stats_email = ArMailer.create_email_stats(missed_shifts, late_shifts, left_early_shifts, department)
  ArMailer.deliver(stats_email)
end


  
desc "Sends out an e-mail to the admin whenever a user misses, is late to, or leaves a shift early"

task (:email_stats => :environment) do
  departments_that_want_admin_emailed = Department.all.select { |d| d.department_config.email_stats }# check stats_email_address is not nil email_stats
  for dept in departments_that_want_admin_emailed
    shift_email(dept)
  end
end

