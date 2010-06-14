def shift_email(department)
  emailed_shifts = department.shifts.active.between(1.day.ago.midnight, Time.now).stats_send
    for shift in emailed_shifts:
        missed_shifts = emailed_shifts.missed
        late_shifts = emailed_shifts.late
        left_early_shifts = emailed_shifts.left_early
    end

   stats_email = ArMailer.create_email_stats(missed_shifts, late_shifts, left_early_shifts, department)
   ArMailer.deliver(stats_email)
end


  
desc "Sends out an e-mail to the admin whenever a user misses, is late to, or leaves a shift early"

task (:email_stats => :environment) do
  departments_that_want_admin_emailed = Department.all.select { |d| d.department_config.# check stats_email_address is not nil email_stats }
  for dept in departments_that_want_admin_emailed
    shift_email(dept)
  end
end

