namespace :email do
  def stale_shift_email(department)
    stale_shifts = []
    stale_shifts = Shift.stale_shifts_with_unsent_emails(department)
  
    for shift in stale_shifts     
      email = ArMailer.create_stale_shift(shift.user, shift, department)
      ArMailer.deliver(email)
      shift.stale_shifts_unsent = false
      shift.save
    end
   
  end


  desc "Sends out an e-mail whenever a student has been signed into a shift and has not updated for over an hour"
  task :stale_shift_reminders => :environment do
    departments_notified_about_stale_shifts = Department.all.select { |d| d.department_config.stale_shift }
    for dept in departments_notified_about_stale_shifts
      stale_shift_email(dept)
    end
  end
  
end