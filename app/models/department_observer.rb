class DepartmentObserver < ActiveRecord::Observer

  #TODO: this conflicts with department_config.rb::default
  # Automatically create department config for a department
  def after_create(department)
    DepartmentConfig.create!({:department_id => department.id,
                        :schedule_start => "9",
                        :schedule_end => "5",
                        :time_increment => 15.minutes,
                        :grace_period => 7.minutes,
                        :edit_report => false,
                        :weekend_shifts => true,
                        :unscheduled_shifts => true
                        })

    Category.create!(:name => "Shifts", :department_id => department.id)
  end
end

