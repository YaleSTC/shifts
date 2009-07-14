class DepartmentObserver < ActiveRecord::Observer

  #TODO: this conflicts with department_config.rb::default
  # Automatically create department config for a department
  def after_create(department)
    DepartmentConfig.create!({:department_id => department.id,
                        :schedule_start => 9*60,
                        :schedule_end => 17*60,
                        :time_increment => 15,
                        :grace_period => 7,
                        :edit_report => false,
                        :end_of_month => false,
                        :monthly => false,
                        :weekend_shifts => true,
                        :unscheduled_shifts => true,
                        :printed_message => "This payform has already been printed and may no longer be edited by you.\n If there is a problem that needs to be addressed, please talk to the administration.",
                        :reminder_message => "Please remember to submit your payform for this week.",
                        :warning_message => "You have not submitted payforms for the weeks ending on the following dates:\n \n@weeklist@\n Please submit your payforms. If some of the weeks listed are weeks during which you did not work, please just submit a blank payform.",
                        :warning_weeks => 2,
                        :description_min => 4,
                        :show_disabled_cats => true,
                        :reason_min => 4,
                        :punch_clock => false
                        })

    Category.create!(:name => "Shifts", :department_id => department.id)
  end
end

                        })

    Category.create!(:name => "Shifts", :department_id => department.id)
  end
end

