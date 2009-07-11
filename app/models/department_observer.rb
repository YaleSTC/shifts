class DepartmentObserver < ActiveRecord::Observer

  # Automatically create department config for a department
  def after_create(department)
    DepartmentConfig.create!({:department_id => department.id,
                        :schedule_start => 9*60,
                        :schedule_end => 17*60,
                        :time_increment => 15,
                        :grace_period => 7,
                        :edit_report => false,
                        :weekend_shifts => true,
                        :unscheduled_shifts => true
                        })
  end
end

