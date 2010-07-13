module TimeSlotsHelper

  def time_slot_style(time_slot, time_slot_day)
    @right_overflow = @left_overflow = false

    #not DRY, thrown in for AJAX reasons for now. sorry :( -ryan
    @dept_start_hour ||= current_department.department_config.schedule_start / 60
    @dept_end_hour ||= current_department.department_config.schedule_end / 60
    @hours_per_day ||= (@dept_end_hour - @dept_start_hour)

    left = ((time_slot.start - (time_slot_day.at_beginning_of_day + @dept_start_hour.hours))/3600.0)/@hours_per_day*100
    width = (time_slot.duration/3600.0) / @hours_per_day * 100
    if left < 0
      width += left
      left = 0
      @left_overflow = true
    end
    if left + width > 100
      width -= (left+width)-100
      @right_overflow = true
    end

    "width: #{width}%; left: #{left}%;"
  end

  def fetch_timeslots(time_slot_day,location)
    result = []
    timeslots = TimeSlot.on_48h(time_slot_day).in_location(location)
    for timeslot in timeslots do

      if ( ( ((timeslot.start < time_slot_day.beginning_of_day + @dept_start_hour.hours) &&
         (timeslot.end    < time_slot_day.beginning_of_day + @dept_start_hour.hours))            &&
         ((timeslot.start > (time_slot_day-1.day).beginning_of_day + @dept_end_hour.hours) &&
         (timeslot.end    > (time_slot_day-1.day).beginning_of_day + @dept_end_hour.hours)) ) ||
         ((timeslot.start > time_slot_day.beginning_of_day + @dept_end_hour.hours) &&
         (timeslot.end    > time_slot_day.beginning_of_day + @dept_end_hour.hours)) )
        @hidden_timeslots << timeslot
      else
        result << timeslot
      end
    end
    result
  end


#calculates default_start/end and range_start/end_time
  def calculate_default_times
    if params[:date]
	  #sometimes from the tooltip, sometimes week start date
      @default_start_date = Date.parse(params[:date])
    elsif @time_slot.start
      @default_start_date = @time_slot.start.to_date
    else #do we ever hit this? ~Casey
      @default_start_date = Time.now.to_date
    end

#    if params[:xPercentage]
#      @time_slot.start = @default_start_date
#      @dept_start_minutes ||= current_department.department_config.schedule_start
#      @dept_end_minutes ||= current_department.department_config.schedule_end
#      @minutes_per_day ||= (@dept_end_minutes - @dept_start_minutes)
#      @time_slot.start += @dept_start_minutes.minutes
#      @time_slot.start += (@minutes_per_day * params[:xPercentage].to_f / 60).to_int * 3600 #truncates the hour
##if the time slot starts off of the hour (at 9:30), this is not ideal because it will select either 9:00 or 10:00 and the following hour. We need timeslot validation first.
##if the schedule starts at 9:30, I'm not sure what happens ~Casey
#      @time_slot.end = @time_slot.start + 1.hour
#    else
      @time_slot.start ||= @default_start_date.to_time + current_department.department_config.schedule_start.minutes
      @time_slot.end ||= @default_start_date.to_time + current_department.department_config.schedule_end.minutes
#    end
    @range_start_time = Time.now.to_date + current_department.department_config.schedule_start.minutes
    @range_end_time = Time.now.to_date + current_department.department_config.schedule_end.minutes

#    @default_end_date = @time_slot.end.to_date
#    @default_end_date -= 1.day if (@time_slot.end.day == (@time_slot.start.day + 1))

  end


end

