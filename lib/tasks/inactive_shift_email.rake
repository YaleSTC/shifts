def inactive_shift_email(department)
  @users = department.active_users.sort_by(&:name)
  for user in @users
    inactive_shifts = departments.shifts.all.active( :conditions => { :user_id => user.id, :department_id => department.id, :submitted => nil }) #define Time that shift was inactive
  
    inactiveshiftlist = []
    for shift in inactive_shifts
      unless shift.signed_in == false
        if (Time.now - shift.report_items.last.created_at) >= 3600 #inactive for an hour
          inactiveshiftlist <<  shift
        end
      end
    end
    unless shift.reminded_inactive == true?
    inactive_shift_email = ArMailer.create_inactive_shift(inactive_shifts, department)
    ArMailer.deliver(inactive_shift_email)
  end
  end
end


desc "Sends out an e-mail whenever a studnet has been signed into a shift and has not updated for over an hour"

task(:inactive_shift => :environment) do
  depts_notified_about_inactive_shifts = Department.all.select { |d| d.department_config.inactive_shifts }
  for dept in depts_notified_about_inactive_shifts
    inactive_shift_email(dept)
  end
end


 

