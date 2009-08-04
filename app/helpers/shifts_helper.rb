module ShiftsHelper
  
  #WILL BE CHANGED TO SHIFTS:
  def shift_style(shift)
    @right_overflow = @left_overflow = false
    
    #necessary for AJAX rerendering
    #we should extract all of this stuff from controllers and here and make a universal shifts helper method -njg
    #(too much duplication -- shifts/dashboard/ajax,etc)
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
  
  
  
  def day_preprocessing(day)
    @location_rows = {}
    for location in Location.all
      @location_rows[location] = []
    end
    
    @hidden_shifts = Shift.hidden_search(day.beginning_of_day + @dept_start_hour.hours + @time_increment.minutes,
                                         day.beginning_of_day + @dept_end_hour.hours - @time_increment.minutes,
                                         day.beginning_of_day, day.end_of_day, current_department)
    shifts = Shift.super_search(day.beginning_of_day + @dept_start_hour.hours,
                                day.beginning_of_day + @dept_end_hour.hours, @time_increment.minutes, current_department)


    rowcount = 0
    rejected = []
    location_row = 0
    
    until shifts.empty?
      shift = shifts.shift
      @location_rows[shift.location][location_row] = [shift]
      (0...shifts.length).each do |i| 
        if shift.location == shifts.first.location
          if shift.end > shifts.first.start
            rejected << shifts.shift
          else
            shift = shifts.shift
            @location_rows[shift.location][location_row] << shift
          end
        else
          shift = shifts.shift
          @location_rows[shift.location][location_row] = [shift]
        end
      end
      location_row += 1
      shifts = rejected
      if location_row > 0
        rowcount += location_row
      else
        rowcount += 1
      end
    end

    @table_height = rowcount + @loc_groups.length * 0.25
    @table_pixels = 26 * rowcount + rowcount+1
  end
  
end

