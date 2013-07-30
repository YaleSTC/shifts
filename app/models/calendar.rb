class Calendar < ActiveRecord::Base
  has_many :shifts
  has_many :time_slots
  has_many :repeating_events
  belongs_to :department

  validates_presence_of :name
  validates_presence_of :start_date
  validates_presence_of :end_date, :if => Proc.new{|calendar| !calendar.default?}

  validates_uniqueness_of :name, :scope => :department_id

  scope :active, -> {where(:active => true)}
  scope :public, -> {where(:public => true)}

  def self.active_in(department, start_date = Time.now, end_date = Time.now)
    active = Calendar.where("department_id = ? and start_date <= ? and end_date >= ? and active is true", department.id, start_date.utc, end_date.utc)
    default = Calendar.where("department_id = ? and `default` is true", department.id).first()
    [default, active].flatten
  end
  
  def self.destroy_self_and_future(calendar)
    default_id = calendar.department.calendars.default.id
    TimeSlot.delete_all("calendar_id  = #{calendar.id  } AND end  > #{Time.now.utc  }")
    TimeSlot.update_all("calendar_id  = #{default_id  }", "calendar_id  = #{calendar.id  }")
    Shift.mass_delete_with_dependencies(Shift.where("calendar_id  = #{calendar.id  } AND end  > #{Time.now.utc  }"))
    Shift.update_all("calendar_id  = #{default_id  }", "calendar_id  = #{calendar.id  }")
    calendar.destroy
  end

  def self.copy(old_calendar, new_calendar, wipe)
    errors = ""

    # old_calendar.repeating_events.each do |r|
    #   new_repeating_event = r.clone
    #   new_repeating_event.start_date = new_calendar.start_date
    #   new_repeating_event.end_date = new_calendar.end_date
    #   new_repeating_event.calendar = new_calendar
    #   new_repeating_event.save!
    #   error = new_repeating_event.make_future(wipe)
    #   errors += ","+error if error
    # end

    old_calendar.time_slots.select{|s| s.repeating_event.nil?}.each do |r|
      new_time_slot = r.clone
      new_time_slot.calendar = new_calendar
      new_time_slot.active = new_calendar.active
      new_time_slot.save!
    end

    old_calendar.shifts.select{|s| s.repeating_event.nil?}.each do |r|
      new_shift = r.clone
      new_shift.calendar = new_calendar
      new_shift.active = new_calendar.active
      new_shift.power_signed_up = true
      new_shift.save(false)
    end
    errors
  end

  def self.wipe_range(start_time, end_time, wipe_timeslots, wipe_shifts, loc_ids, cal_ids)
    if wipe_timeslots
      loc_ids.each do |loc_id|
        cal_ids.each do |cal_id|
          TimeSlot.delete_all("start  > #{start_time.utc  } AND start  < #{end_time  } AND calendar_id  = #{cal_id  } AND location_id  = #{loc_id  }")
        end
      end
    end
    if wipe_shifts
      loc_ids.each do |loc_id|
        cal_ids.each do |cal_id|
          Shift.mass_delete_with_dependencies(Shift.where("start  > #{start_time.utc  } AND start  < #{end_time  } AND calendar_id  = #{cal_id  } AND location_id  = #{loc_id  }"))
        end
      end
    end
  end

  def deactivate
    self.active = false
    TimeSlot.update_all("active  = #{false  }", "calendar_id  = #{self.id  } AND start > #{Time.now.utc  }")
    Shift.update_all("active  = #{false  }", "calendar_id  = #{self.id  } AND start > #{Time.now.utc  }")
    self.save
  end

  def activate(wipe)
    self.active = true
    conflicts = Shift.check_for_conflicts(Shift.where("calendar_id = #{self.id  } AND start > #{Time.now.utc  }"), wipe) + TimeSlot.check_for_conflicts(TimeSlot.where("calendar_id = #{self.id  } AND start > #{Time.now.utc  }"), wipe)
    if conflicts.empty?
      TimeSlot.update_all("active  = #{true  }", "calendar_id  = #{self.id  } AND start  > #{Time.now.utc  }")
      Shift.update_all("active  = #{true  }", "calendar_id  = #{self.id  } AND start } > #{Time.now.utc  }")
      self.save
      return false
    else
      return conflicts
    end
  end

end
