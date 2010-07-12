module RepeatingEventsHelper


  #duplicated from time_slots helper, to fix things for the time being. TODO: cleanup.
  def fetch_timeslots(time_slot_day,location)
    result = []
    timeslots = TimeSlot.all(:conditions => ['start > ? and start < ? and location_id = ?',time_slot_day.beginning_of_day,time_slot_day.end_of_day,location.id])
    for timeslot in timeslots do
      if ((timeslot.start < timeslot.start.beginning_of_day + @dept_start_hour.hours) &&
         (timeslot.end    < timeslot.start.beginning_of_day + @dept_start_hour.hours)) ||
         ((timeslot.start > timeslot.start.beginning_of_day + @dept_end_hour.hours) &&
         (timeslot.end    > timeslot.start.beginning_of_day + @dept_end_hour.hours))
        @hidden_timeslots << timeslot
      else
        result << timeslot
      end
    end
    result
  end

  def calculate_default_times_repeating_events
    @default_start_date = Time.now.to_date
    @repeating_event.start_time ||= @default_start_date.to_time + current_department.department_config.schedule_start.minutes
    @repeating_event.end_time ||= @default_start_date.to_time + current_department.department_config.schedule_end.minutes
    @range_start_time = Time.now.to_date + current_department.department_config.schedule_start.minutes
    @range_end_time = Time.now.to_date + current_department.department_config.schedule_end.minutes
  end


end
