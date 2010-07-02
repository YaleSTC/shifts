module TimeSlotsHelper

  def time_slot_style(time_slot)
    @right_overflow = @left_overflow = false

    #not DRY, thrown in for AJAX reasons for now. sorry :( -ryan
    @dept_start_hour ||= current_department.department_config.schedule_start / 60
    @dept_end_hour ||= current_department.department_config.schedule_end / 60
    @hours_per_day ||= (@dept_end_hour - @dept_start_hour)

    left = ((time_slot.start - (time_slot.start.at_beginning_of_day + @dept_start_hour.hours))/3600.0)/@hours_per_day*100
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
    #timeslots = TimeSlot.all(:conditions => ['start >= ? and start < ? and location_id = ?',time_slot_day.beginning_of_day,time_slot_day.end_of_day,location.id])
    timeslots = TimeSlot.on_day(time_slot_day).in_location(location)
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


#calculates default_start/end and range_start/end_time
  def calculate_default_times
    #Case 1 - validation failed, so the form is redisplayed
    #I haven't decided if Case 1 is necessary here, but it's not hurting ~Casey
    if params[:time_slot]
      @default_start = params[:time_slot][:start_date].to_date.to_time + params[:time_slot][:start_time].seconds_since_midnight
      @default_end = params[:time_slot][:end_date].to_date.to_time + params[:time_slot][:end_time].seconds_since_midnight
    #Case 2 - start with info from the shift being edited
    elsif params[:id]
      @default_start = @time_slot.start
      @default_end = @time_slot.end
    #Case 3 - start with info from timeline
    elsif params[:xPercentage]
      @default_start = (params[:date] ? Time.parse(params[:date]) : Time.now).to_date
      @dept_start_minutes ||= current_department.department_config.schedule_start
      @dept_end_minutes ||= current_department.department_config.schedule_end
      @minutes_per_day ||= (@dept_end_minutes - @dept_start_minutes)
      @default_start += @dept_start_minutes.minutes
      @default_start += (@minutes_per_day * params[:xPercentage].to_f / 60).to_int * 3600 #truncates the hour
#if the time slot starts off of the hour (at 9:30), this is not ideal because it will select either 9:00 or 10:00 and the following hour. We need timeslot validation first.
#if the schedule starts at 9:30, I'm not sure what happens ~Casey
      @default_end = @default_start + 1.hour
  #Case 4 - nothing to start with (shifts/new)
    else
      @default_start = (params[:date] ? Time.parse(params[:date]) : Time.now).to_date.to_time + current_department.department_config.schedule_start.minutes
      @default_end = (params[:date] ? Time.parse(params[:date]) : Time.now).to_date.to_time + current_department.department_config.schedule_end.minutes
    end

    @range_start_time = Time.now.to_date + current_department.department_config.schedule_start.minutes
    @range_end_time = Time.now.to_date + current_department.department_config.schedule_end.minutes

  end

end

#      @default_start = Date.today.to_time + 13.hours

