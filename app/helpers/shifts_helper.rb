module ShiftsHelper
  
  #WILL BE CHANGED TO SHIFTS:
  def shift_style(shift)
    @right_overflow = @left_overflow = false
    
    #necessary for AJAX rerendering
    @dept_start_hour ||= current_department.department_config.schedule_start / 60
    @dept_end_hour = current_department.department_config.schedule_end / 60
    @hours_per_day ||= (@dept_end_hour - @dept_start_hour)
    
    left = ((shift.start - (shift.start.beginning_of_day + @dept_start_hour.hours))/3600.0)/@hours_per_day*100
    width = ((shift.end - shift.start)/3600.0) / @hours_per_day * 100
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
  
end

