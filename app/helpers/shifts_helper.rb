module ShiftsHelper

  #WILL BE CHANGED TO SHIFTS:
  def shift_style(shift, after = nil)
    @right_overflow = @left_overflow = false

    #necessary for AJAX rerendering
    #we should extract all of this stuff from controllers and here and make a universal shifts helper method -njg
    #(too much duplication -- shifts/dashboard/ajax,etc)
    @dept_start_hour ||= current_department.department_config.schedule_start / 60
    @dept_end_hour ||= current_department.department_config.schedule_end / 60
    @hours_per_day ||= (@dept_end_hour - @dept_start_hour)

    left = (((after ? after : shift.start) - (shift.start.beginning_of_day + @dept_start_hour.hours))/3600.0)/@hours_per_day*100
    width = ((shift.end - (after ? after : shift.start))/3600.0) / @hours_per_day * 100
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

  def loc_group_preprocessing
    @unfilled_priority = {}
    @unfilled_priority.default = false
  end

  def location_preprocessing(location, day)
    timeslots = @location_rows_timeslots[location]
    shifts = @location_rows[location].flatten

    #what times is this location open?
    @open_at = {}
    @open_at.default = false
    unless timeslots.nil?
      timeslots.each do |timeslot|
        time = timeslot.start
        time = time.hour*60+time.min
        end_time = timeslot.end
        end_time = end_time.hour*60+end_time.min
        end_time += (24*60) if end_time <= time #for slots ending at/after midnight
        while (time < end_time)
          @open_at[time] = true
          time += @time_increment
        end
      end
    end

    #how many people are in this location?
    people_count = {}
    people_count.default = 0
    unless shifts.nil?
      shifts.each do |shift|
        time = shift.start
        time = time.hour*60+time.min
        end_time = shift.end
        end_time = end_time.hour*60+end_time.min
        end_time += (24*60) if end_time <= time #for slots ending at/after midnight
        while (time < end_time)
          people_count[time] += 1
          time += @time_increment
        end
      end
    end

    #what should the bar display?
    @signup_bar = []
    @total_blocks = @blocks_per_hour * @hours_per_day
    now = Time.now
    now = now.hour*60+now.min
    today = day.today?
    (0...@total_blocks).each do |block|
      time = @dept_start_hour*60 + block*@time_increment
      if today and time < now
        @signup_bar[block] = "bar_passed no_signups"
      elsif !@open_at[time] or !current_user.can_signup?(location.loc_group)
        @signup_bar[block] = "bar_closed no_signups"
      elsif people_count[time] >= location.max_staff
        @signup_bar[block] = "bar_full no_signups"
      elsif @unfilled_priority[time] and location.priority < @unfilled_priority[time]
        @signup_bar[block] = "bar_pending no_signups"
      else
        @signup_bar[block] = "bar_open click_to_add_new"
        if(people_count[time] < location.min_staff)
          @unfilled_priority[time] ||= location.priority
        end
      end
    end
  end

  def min_staff_not_met?(time, location)
    @open_at[time.to_s(:am_pm)] && people_count[time.to_s(:am_pm)] < location.min_staff
  end


#calculates default_start/end and range_start/end_time
  def calculate_default_times

    @default_start_date = (params[:date] ? Time.parse(params[:date]) : Time.now).to_date
    if params[:xPercentage]
      @shift.start = @default_start_date
      @dept_start_minutes ||= current_department.department_config.schedule_start
      @dept_end_minutes ||= current_department.department_config.schedule_end
      @minutes_per_day ||= (@dept_end_minutes - @dept_start_minutes)
      @shift.start += @dept_start_minutes.minutes
      @shift.start += (@minutes_per_day * params[:xPercentage].to_f / 60).to_int * 3600 #truncates the hour
#if the time slot starts off of the hour (at 9:30), this is not ideal because it will select either 9:00 or 10:00 and the following hour. We need timeslot validation first.
#if the schedule starts at 9:30, I'm not sure what happens ~Casey
      @shift.end = @shift.start + 1.hour
    else
      @shift.start ||= (params[:date] ? Time.parse(params[:date]) : Time.now).to_date.to_time + current_department.department_config.schedule_start.minutes
      @shift.end ||= @shift.start + 1.hour
    end
    @range_start_time = Time.now.to_date + current_department.department_config.schedule_start.minutes
    @range_end_time = Time.now.to_date + current_department.department_config.schedule_end.minutes

  end



  def day_preprocessing(day)
    @location_rows = {}

    #for AJAX; needs cleanup if we have time
    @loc_groups = current_user.user_config.view_loc_groups.select{|l| !l.locations.empty?}
    @dept_start_hour ||= current_department.department_config.schedule_start / 60
    @dept_end_hour ||= current_department.department_config.schedule_end / 60
    @hours_per_day ||= (@dept_end_hour - @dept_start_hour)
    @time_increment ||= current_department.department_config.time_increment
    @blocks_per_hour ||= 60/@time_increment.to_f

    @visible_locations ||= current_user.user_config.view_loc_groups.collect{|l| l.locations}.flatten
    #locations = @loc_groups.map{|lg| lg.locations}.flatten
    for location in @visible_locations
      @location_rows[location] = [] #initialize rows
      @location_rows[location][0] = [] #initialize rows
    end

    # @hidden_shifts = Shift.hidden_search(day.beginning_of_day + @dept_start_hour.hours + @time_increment.minutes,
    #                                      day.beginning_of_day + @dept_end_hour.hours - @time_increment.minutes,
    #                                      day.beginning_of_day, day.end_of_day, locations.map{|l| l.id})
    # shifts = Shift.super_search(day.beginning_of_day + @dept_start_hour.hours,
    #                             day.beginning_of_day + @dept_end_hour.hours, @time_increment.minutes, locations.map{|l| l.id})

    @visible_locations ||= current_user.user_config.view_loc_groups.collect{|l| l.locations}.flatten

    shifts = Shift.active.in_locations(@visible_locations).on_day(day).scheduled #TODO: .active
    shifts ||= []
    shifts = shifts.sort_by{|s| [s.location_id, s.start]}

    # TODO: FIX ME
    @hidden_shifts = Shift.hidden_search(day.beginning_of_day + @dept_start_hour.hours + @time_increment.minutes,
                                         day.beginning_of_day + @dept_end_hour.hours - @time_increment.minutes,
                                         day.beginning_of_day, day.end_of_day, @visible_locations.map{|l| l.id})

    timeslots = TimeSlot.active.in_locations(@visible_locations).on_day(day).after_now #TODO: .active

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


  #this is super-un-DRY, but AJAX calls to the shifts controller from the calendar controller
  #try to rerender the calendar view, and fail if they can't find this function. if there's
  #time, this could probably be cleaned up somehow.
  def calendar_day_preprocessing(day)
    @location_rows = {}
    @location_rows_timeslots = {}

    #different calendars are different colors
    unless defined? @color
      @color_array ||= ["9f9", "9ff", "ff9", "f9f", "f99", "99f", "399","933","393","c60","60c","0c6","6c0","c06","06c"]
      @color ||= {}
      @calendar = (params[:calendar] == "true" ? nil : Calendar.find(params[:calendar]) )
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

    @visible_locations ||= current_user.user_config.view_loc_groups.collect{|l| l.locations}.flatten
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

    @visible_locations ||= current_user.user_config.view_loc_groups.collect{|l| l.locations}.flatten

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

