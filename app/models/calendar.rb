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
    default = Calendar.where("department_id = ? and `default` is true", department.id).first
    [default, active].flatten
  end

  def self.destroy_self_and_future(calendar)
    default_id = calendar.department.calendars.default.id

    TimeSlot.delete_all(["calendar_id = ? AND start > ?", calendar.id, Time.now.utc)
    TimeSlot.update_all(["calendar_id  = ", default_id], ["calendar_id  = ?"], calendar.id)

    future_shifts_on_calendar = Shift.where("calendar_id = ? AND start > ?", calendar.id, Time.now.utc)
    Shift.mass_delete_with_dependencies(future_shifts_on_calendar)
    Shift.update_all(["calendar_id  = ?", default_id], ["calendar_id  = ?", calendar.id])

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
          values = [start_time.utc, end_time.utc, cal_id, loc_id]
          TimeSlot.delete_all(["start > ? AND start  < ? AND calendar_id = ? AND location_id  = ?", *values])
        end
      end
    end
    if wipe_shifts
      loc_ids.each do |loc_id|
        cal_ids.each do |cal_id|
          values = [start_time.utc, end_time.utc, cal_id, loc_id]
          Shift.mass_delete_with_dependencies(Shift.where("start > ? AND start  < ? AND calendar_id = ? AND location_id  = ?", *values))
        end
      end
    end
  end

  def deactivate
    self.active = false
    conditions = ["calendar_id  = ? AND start > ?", self.id, Time.now.utc]
    TimeSlot.where(conditions).update_all(active: false)
    Shift.where(conditions).update_all(active: false)
    self.save
  end

  def activate(wipe)
    self.active = true
    conditions = ["calendar_id  = ? AND start > ?", self.id, Time.now.utc]
    conflicts = Shift.check_for_conflicts(Shift.where(conditions), wipe) +
                TimeSlot.check_for_conflicts(TimeSlot.where(conditions), wipe)
    if conflicts.empty?
      TimeSlot.where(conditions).update_all(active: true)
      Shift.where(conditions).update_all(active: true)
      self.save
      return false
    else
      return conflicts
    end
  end

end
