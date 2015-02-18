namespace :email do
  def stale_shift_email(department)
    stale_shifts = Shift.stale_shifts_with_unsent_emails(department)
  
    for shift in stale_shifts     
      UserMailer.delay.stale_shift(shift.user, shift, department)
      shift.stale_shifts_unsent = false
      shift.save
    end

    puts "#{stale_shifts.length} users in the #{department.name} department "  +
           "have been reminded to update their shift reports."
   
  end


  desc "Sends out an e-mail whenever a student has been signed into a shift and has not updated for over an hour"

  task stale_shift_reminders: :environment do
    departments_notified_about_stale_shifts = Department.all.select { |d| d.department_config.stale_shift }
    for dept in departments_notified_about_stale_shifts
      stale_shift_email(dept)
    end
  end
  
end
