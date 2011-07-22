module RepeatingEventsHelper

  def department_checked?(dept, repeating_event)
   repeating_event.departments.each do |d|
      return true if d == dept
    end
    false
  end

  def loc_group_checked?(loc_group, repeating_event)
    checked = true
    current_department.loc_groups.each do |lg|
      if lg == loc_group
        lg.locations.each do |loc|
          checked = false unless @repeating_event.location_ids && @repeating_event.location_ids.include?(loc.id)
        end
      end
    end
    return checked
  end

  def location_checked?(location, repeating_event)
    return true if @repeating_event.location_ids && @repeating_event.location_ids.include?(location.id)
#    current_department.locations.each do |loc|
#      return true if loc == location
#    end
		false
  end


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


end

