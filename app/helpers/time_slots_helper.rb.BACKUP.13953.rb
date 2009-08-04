module TimeSlotsHelper
  
  def time_slot_style(time_slot)
    @right_overflow = @left_overflow = false
    left = ((time_slot.start - (time_slot.start.at_beginning_of_day + @dept_start_hour.hours))/3600.0)/@hours_per_day*100
    width = (time_slot.duration/3600.0) / @hours_per_day * 100
    if left < 0
      width -= left
      left = 0 
<<<<<<< HEAD:app/helpers/time_slots_helper.rb
    elsif left > 100
      left=0
      width=100/@hours_per_day
=======
      @left_overflow = true
>>>>>>> 45db63f955ebf7fc3314d20af16caf0307ebad7b:app/helpers/time_slots_helper.rb
    end
    if left + width > 100
      width -= (left+width)-100
      @right_overflow = true
    end
    
    "width: #{width}%; left: #{left}%;"
  end
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
