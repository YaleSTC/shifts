module TimeSlotsHelper
  
  def time_slot_style(time_slot)
    left = ((time_slot.start - (time_slot.start.at_beginning_of_day + @dept_start_hour.hours))/3600.0)/@hours_per_day*100
    width = (time_slot.duration/3600.0) / @hours_per_day * 100
    if left < 0 
      width -= left
      left = 0 
    end  
    if 100-left + width > 100
      width = 100-left
    end
    "width: #{width}%; left: #{left}%;"
  end
end
