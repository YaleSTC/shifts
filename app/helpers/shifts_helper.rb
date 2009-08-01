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
    rowcount = 1
    @hidden_shifts = []
    @location_rows = {}
    for location in @loc_groups.map{|lg| lg.locations }.flatten.uniq
      shifts = Shift.on_day(day).in_location(location).scheduled.sort_by{|s| s.start }
      rejected = []
      @location_rows[location] = []
      @location_rows[location][0] = []
      location_row = 0
      until shifts.empty?
        shift = shifts.shift #get first shift. shift... haha. (array.shift is a function)
        @location_rows[location][location_row] = []
        found_first = false
        while !found_first
          if (shift.end < day.beginning_of_day + @dept_start_hour.hours + @time_increment.minutes) ||
             (shift.start > day.beginning_of_day + @dept_end_hour.hours - @time_increment.minutes)
            @hidden_shifts << shift
            shift = shifts.shift
          else
            @location_rows[location][location_row] << shift
            found_first = true
          end
        end
        (0...shifts.length).each do
          if (shifts.first.end < day.beginning_of_day + @dept_start_hour.hours + @time_increment.minutes) ||
             (shifts.first.start > day.beginning_of_day + @dept_end_hour.hours - @time_increment.minutes)
            @hidden_shifts << shifts.shift
          elsif shift.end > shifts.first.start
            rejected << shifts.shift
          else
            shift = shifts.shift
            @location_rows[location][location_row] << shift
          end
        end
        location_row += 1
        shifts = rejected
      end
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

