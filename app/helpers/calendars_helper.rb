module CalendarsHelper
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
  
  # def day_preprocessing(day)
  #   @location_rows = {}
  #
  #   for location in @visible_locations
  #     @location_rows[location] = [] #initialize rows
  #   end
  #
  #   # @hidden_shifts = Shift.hidden_search(day.beginning_of_day + @dept_start_hour.hours + @time_increment.minutes,
  #   #                                      day.beginning_of_day + @dept_end_hour.hours - @time_increment.minutes,
  #   #                                      day.beginning_of_day, day.end_of_day, locations.map{|l| l.id})
  #   # shifts = Shift.super_search(day.beginning_of_day + @dept_start_hour.hours,
  #   #                             day.beginning_of_day + @dept_end_hour.hours, @time_increment.minutes, locations.map{|l| l.id})
  #   shifts = @shifts[day.to_s("%Y-%m-%d")]
  #   shifts ||= []
  #   shifts = shifts.sort_by{|s| [s.location_id, s.start]}
  #
  #   timeslots = @time_slots[day.to_s("%Y-%m-%d")]
  #   timeslots ||= []
  #   timeslots = timeslots.sort_by{|t| [t.location_id, t.start]}
  #
  #   rejected = []
  #   location_row = 0
  #
  #   until shifts.empty?
  #     shift = shifts.shift
  #     @location_rows[shift.location][location_row] = [shift]
  #     (0...shifts.length).each do |i|
  #       if shift.location == shifts.first.location
  #         if shift.end > shifts.first.start
  #           rejected << shifts.shift
  #         else
  #           shift = shifts.shift
  #           @location_rows[shift.location][location_row] << shift
  #         end
  #       else
  #         shift = shifts.shift
  #         @location_rows[shift.location][location_row] = [shift]
  #       end
  #     end
  #     location_row += 1
  #     shifts = rejected
  #   end
  #
  #   # insert an extra empty row for timeslots in calendar view
  #   # for location in @visible_locations
  #   #   @location_rows[location][@location_rows[location].length] = [nil]
  #   # end
  #
  #   rowcount = 1 #starts with the bar on top
  #   for location in @visible_locations
  #     rowcount += @location_rows[location].length
  #     rowcount += 0.5 #timeslot bar
  #   end
  #
  #   @table_height = rowcount + @visible_loc_groups.length * 0.25
  #   @table_pixels = 26 * rowcount + rowcount+1
  # end
  def calendar_day_preprocessing(day)
    @location_rows = {}
    @location_rows_timeslots = {}


    #different calendars are different colors
    unless defined? @color
      @color_array ||= ["9f9", "9ff", "ff9", "f9f", "f99", "99f", "399","933","393","c60","60c","0c6","6c0","c06","06c"]
      @color ||= {}
      @calendar ||= (params[:calendar] == "true" ? nil : Calendar.find(params[:calendar]) )
      @calendars ||= (params[:calendar] == "true" ? @department.calendars : [Calendar.find(params[:calendar])] )
      @calendars.each_with_index{ |calendar, i| @color[calendar] ||= @color_array[i]}
    end


    #for AJAX; needs cleanup if we have time
    @loc_groups = current_user.user_config.view_loc_groups.select{|l| !l.locations.empty?}
    @dept_start_hour ||= current_department.department_config.schedule_start / 60
    @dept_end_hour ||= current_department.department_config.schedule_end / 60
    @hours_per_day ||= (@dept_end_hour - @dept_start_hour)
    @time_increment ||= current_department.department_config.time_increment
    @blocks_per_hour ||= 60/@time_increment.to_f

    @visible_locations ||= current_user.user_config.view_loc_groups.collect{|l| l.locations}.flatten.select{|l| l.active?}
    #locations = @loc_groups.map{|lg| lg.locations}.flatten
    for location in @visible_locations
      @location_rows[location] = [] #initialize rows
      @location_rows[location][0] = [] #initialize rows
      @location_rows_timeslots[location] = []
    end

    # @hidden_shifts = Shift.hidden_search(day.beginning_of_day + @dept_start_hour.hours + @time_increment.minutes,
    #                                      day.beginning_of_day + @dept_end_hour.hours - @time_increment.minutes,
    #                                      day.beginning_of_day, day.end_of_day, locations.map{|l| l.id})
    # shifts = Shift.super_search(day.beginning_of_day + @dept_start_hour.hours,
    #                             day.beginning_of_day + @dept_end_hour.hours, @time_increment.minutes, locations.map{|l| l.id})

    @visible_locations ||= current_user.user_config.view_loc_groups.collect{|l| l.locations}.flatten.select{|l| l.active?}

    shifts = Shift.in_calendars(@calendars).in_locations(@visible_locations).on_day(day).scheduled
    shifts ||= []
    shifts = shifts.sort_by{|s| [s.location_id, s.start]}

    # TODO: FIX ME
    @hidden_shifts = Shift.hidden_search(day.beginning_of_day + @dept_start_hour.hours + @time_increment.minutes,
                                         day.beginning_of_day + @dept_end_hour.hours - @time_increment.minutes,
                                         day.beginning_of_day, day.end_of_day, @visible_locations.map{|l| l.id})

    timeslots = TimeSlot.in_calendars(@calendars).in_locations(@visible_locations).on_day(day)
    #timeslots = TimeSlot.in_locations(@visible_locations).on_day(day)

    timeslots ||= {}
    timeslots = timeslots.group_by(&:location)

    timeslots.each_key do |location|
      timeslots[location] = timeslots[location].sort_by(&:start)
    end
    @location_rows_timeslots = timeslots

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
    end

    # insert an extra empty row for timeslots in calendar view
    for location in @visible_locations
      @location_rows[location][@location_rows[location].length] = [nil]
    end

    rowcount = 1 #starts with the bar on top
    for location in @visible_locations
      rowcount += (@location_rows[location].length > 0 ? @location_rows[location].length : 1)
    end

    @timeslot_rows = 0 #counter

    @row_height = 24 #pixels - this could be user-configurable
    @divider_height = 3 #pixels - this could be user-configurable
    @table_height = rowcount
    @table_pixels = @row_height * rowcount + rowcount+1
  end
end
