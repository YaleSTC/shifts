module RequestedShiftsHelper

  def calculate_default_times_requested_shifts
    if params[:xPercentage]
      @requested_shift.preferred_start ||= Date.today
      @dept_start_minutes ||= current_department.department_config.schedule_start
      @dept_end_minutes ||= current_department.department_config.schedule_end
      @minutes_per_day ||= (@dept_end_minutes - @dept_start_minutes)
      @requested_shift.preferred_start += @dept_start_minutes.minutes
      @requested_shift.preferred_start += (@minutes_per_day * params[:xPercentage].to_f / 60).to_int * 3600 #truncates the hour
#if the time slot starts off of the hour (at 9:30), this is not ideal because it will select either 9:00 or 10:00 and the following hour. We need timeslot validation first.
#if the schedule starts at 9:30, I'm not sure what happens ~Casey
      @requested_shift.preferred_end = @requested_shift.preferred_start + @shift_preference.min_continuous_hours.hour
    else
      @requested_shift.preferred_start ||= Time.now.beginning_of_day + current_department.department_config.schedule_start.minutes
      @requested_shift.preferred_end ||= @requested_shift.preferred_start + @shift_preference.min_continuous_hours.hour
    end

    @requested_shift.acceptable_start ||= @requested_shift.preferred_start
    @requested_shift.acceptable_end ||= @requested_shift.preferred_end

    @range_start_time = Time.now.to_date + current_department.department_config.schedule_start.minutes
    @range_end_time = Time.now.to_date + current_department.department_config.schedule_end.minutes
  end

end
