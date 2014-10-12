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
    @schedule_width ||= (3600.0 * @hours_per_day)

    if !shift.end
      shift.end = Time.now
    elsif shift.end <= shift.start + current_department.department_config.time_increment.minutes
      shift.end = shift.start + current_department.department_config.time_increment.minutes
    end

    schedule_start_time = shift.start.change(hour: @dept_start_hour)
    draw_start_time = after || shift.start

    left  = 100 * (draw_start_time - schedule_start_time) / @schedule_width
    width = 100 * (shift.end - draw_start_time) / @schedule_width

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
        if shift.end
          end_time = shift.end
        else
          end_time = Time.now
        end
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

  def staffed?(time, location)
    @open_at[time.to_s(:am_pm)] && people_count[time.to_s(:am_pm)] < 1
  end

  def min_staff_not_met?(time, location)
    @open_at[time.to_s(:am_pm)] && people_count[time.to_s(:am_pm)] < location.min_staff
  end

#calculates whether the student is signing into a shift earlier than the allowed dept time
  def within_sign_in_window?(shift)
    (shift.start - Time.now)  <=  current_department.department_config.early_signin.minutes
  end

#calculates default_start/end and range_start/end_time
  def calculate_default_times_shifts
    if @shift.new_record? #true for new html&tooltip
      @default_start_date = (params[:date] ? Time.parse(params[:date]) : Time.now).to_date
    else # true for edit html&tooltip
      @default_start_date = @shift.start
    end

    #set default range for time_select box. Not limited by time_slot since user not in ToolTip view
    #the date doesn't matter for range_start_time, only the time
      @range_start_time = Date.today.to_time + current_department.department_config.schedule_start.minutes
      @range_end_time = Date.today.to_time  + current_department.department_config.schedule_end.minutes

    if params[:xPercentage] #Using ToolTip view
        @shift.start = @default_start_date
        config = current_department.department_config
        minutes_per_day = config.schedule_end - config.schedule_start
        @shift.start += config.schedule_start
        @shift.start += (minutes_per_day * params[:xPercentage].to_f / 60).to_int * 3600 #truncates the hour
        #if the time slot starts off of the hour (at 9:30), this is not ideal because it will select either 9:00 or 10:00 and the following hour. We need timeslot validation first.
        #if the schedule starts at 9:30, I'm not sure what happens ~Casey
        @shift.end = @shift.start + 1.hour
      #limit time_select range to valid time_slots (note: this only applys to ToolTip view)
        timeslot_start = TimeSlot.overlaps(@shift.start, @shift.end).ordered_by_start.first
        timeslot_end = TimeSlot.overlaps(@shift.start, @shift.end).ordered_by_start.last
        if timeslot_start && timeslot_end && !params[:power_signed_up]
          @range_start_time = timeslot_start.start
          @range_end_time = timeslot_end.end
        end
    else   # Not using ToolTip View
      #start already exists when editing, this just sets it for the new html view
        @shift.start ||= (params[:date] ? Time.parse(params[:date]) : Time.now).to_date.to_time + current_department.department_config.schedule_start.minutes
        @shift.end ||= @shift.start + 1.hour
    end
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
    #adding the option to view unscheduled shifts
    if current_department.department_config.unscheduled_shifts == true
      shifts = Shift.active.in_locations(@visible_locations).on_day(day) #TODO: .active
    else
      shifts = Shift.active.in_locations(@visible_locations).on_day(day).scheduled
    end
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

#much of this logic goes toward having three rows in the TTO - 'rejected' just means rejected from the current line, being placed instead on a lower line. Nothing should be permanently 'rejected' in this process.
    until shifts.empty?
      shift = shifts.shift
      if !shift.end
        shift.end = Time.now
      elsif shift.end <= shift.start + current_department.department_config.time_increment.minutes
        shift.end = shift.start + current_department.department_config.time_increment.minutes
      end
      @location_rows[shift.location][location_row] = [shift]
      (0...shifts.length).each do |i|
        if shift.location == shifts.first.location
          if shift.end
            shift_end = shift.end
          else
            shift_end = Time.now
          end
          if shift_end > shifts.first.start
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

    @row_height = 48 #pixels - this could be user-configurable
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
      @color_array = ["9f9", "9ff", "ff9", "f9f", "f99", "99f"]
      @color ||= {}
      @calendar = (params[:calendar] == "true" ? nil : Calendar.find(params[:calendar]) )
      @calendars ||= (params[:calendar] == "true" ? @department.calendars : [Calendar.find(params[:calendar])] )
      @calendars.each_with_index{ |calendar, i| @color[calendar] ||= @color_array[i%6]}
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

    @row_height = 48 #pixels - this could be user-configurable
    @divider_height = 3 #pixels - this could be user-configurable
    @table_height = rowcount
    @table_pixels = @row_height * rowcount + rowcount+1
  end

end
