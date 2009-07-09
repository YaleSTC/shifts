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
                        :unscheduled_shifts => true
                        })
  end
end

