class DepartmentObserver < ActiveRecord::Observer

  # Automatically create department config for a department
  def after_create(department)
    DepartmentConfig.create!({:department_id => department.id,
                        :schedule_start => Time.parse("9:00AM"),
                        :schedule_end => Time.parse("5:00PM"),
                        :time_increment => 15.minutes,
                        :grace_period => 7.minutes,
                        :edit_report => false,
                        :weekend_shifts => true,
                        :unscheduled_shifts => true,
                        :printed_message => "This payform has already been printed and may no longer be edited by you.\n" +
                                            "If there is a problem that needs to be addressed, please talk to the administration.",
                        :reminder_message => "Please remember to submit your payform for the week.",
                        :warning_message => "You have not submitted payforms for the weeks ending on the following dates:\n" +
                                            "\n@weeklist@\n" +
                                            "Please submit your payforms. If some of the weeks listed are weeks during which you did not work, please just submit a blank payform.",
                        :warning_weeks => 4,
                        :description_min => 4,
                        :show_disabled_cats => true,
                        :reason_min => 4,
                        :punch_clock => false
                        })
  end
end

