class Task < ActiveRecord::Base
  has_many :shifts_tasks
  has_many :shifts, through: :shifts_tasks
  belongs_to :location

  validates_uniqueness_of :name
  validates_presence_of :name, :kind
  validate :start_less_than_end
  validates_format_of :link, with: /^(http|https):\/\/[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(:[0-9]{1,5})?(\/.*)?$/ix


  scope :active, -> { where(active: true) }
  scope :after_now, -> { where("end >= ?", Time.now.utc) }
  scope :in_locations, ->(loc_array){ where(location_id: loc_array ) }
  scope :in_location, ->(location){ where(location_id: location) }
  scope :hourly, -> { where(kind: "Hourly") }
  scope :daily, -> { where(kind: "Daily") }
  scope :weekly, -> { where(kind: "Weekly") }
  scope :after_time, ->(time){ where("time > ?", time) }
  scope :between, ->(start, stop){ where("start >= ? and start < ?", start.utc, stop.utc) }

  #done shifts are crossed out in their locations
  def done
    @last_completion = ShiftsTask.find_all_by_task_id(self.id).select{|st| st.task_id == self.id}.last #use find method
    if @last_completion
      if (self.kind == "Hourly") && completed_this_hour?(@last_completion) && completed_today?(@last_completion)
        return true
      elsif (self.kind == "Daily") && completed_today?(@last_completion)
        return true
      elsif (self.kind == "Weekly") && completed_this_week?(@last_completion)
        return true
      else
        return false
      end
    else
      return false
    end
  end

  #delayed tasks show up with a 'needs doing' tag in their location
  def needs_doing
    @last_completion = ShiftsTask.find_all_by_task_id(self.id).select{|st| st.task_id == self.id}.last #use find method
    if @last_completion
      hours_since = (Time.now - @last_completion.created_at)/3600
      hours_since_scheduled = (Time.now)
      if self.done
        return false
      elsif (self.kind == "Hourly") && (hours_since >= 1)
        return true
      elsif (self.kind == "Daily") && (self.right_time)
        return true
      elsif (self.kind == "Weekly") && ((self.right_time && self.right_day) || self.delayed_day)
        return true
      else
        return false
      end
    else
      return false
    end
  end

  #missed tasks are tasks that need doing that have not been done past a certain time
  def missed
    @last_completion = ShiftsTask.find_all_by_task_id(self.id).select{|st| st.task_id == self.id}.last #use find method
    if @last_completion
      hours_since = (Time.now - @last_completion.created_at)/3600
      hours_since_scheduled = (Time.now)
      if self.done
        return false
      elsif (self.kind == "Hourly") && (hours_since >= (1 + (location.department.department_config.task_leniency)/60)) #if a task has not been done for an hour after it has been done, it is considered missed
        return true
      elsif (self.kind == "Daily") && (self.late_time)
        return true
      elsif (self.kind == "Weekly") && (self.delayed_day || (self.late_time && self.right_day))
        return true
      else
        return false
      end
    else
      return false
    end
  end


  #returns boolean if now is after scheduled time for task today; does not respect designated days for weekly tasks
  def right_time
    scheduled_time = self.time_of_day.seconds_since_midnight
    now_time = Time.now.seconds_since_midnight
    seconds_past_scheduled = now_time - scheduled_time
    if seconds_past_scheduled > 0 && seconds_past_scheduled < location.department.department_config.task_leniency.minutes   #needs doing if not done within an hour
      return true
    elsif self.kind == "Hourly" #not exactly valid interpretation, since hourly tasks shouldn't have a time_of_day; to prevent nil value errors
      return true
    else
      return false
    end
  end

  #returns a boolean if an hour has passed after the scheduled task was supposed to be done.
  def late_time
    scheduled_time = self.time_of_day.seconds_since_midnight
    now_time = Time.now.seconds_since_midnight
    seconds_past_scheduled = now_time - scheduled_time
    if seconds_past_scheduled >= location.department.department_config.task_leniency.minutes
      return true
    elsif self.kind == "Hourly"
    else
      return false
    end
  end

  #returns boolean if today is the correct day for a weekly task
  def right_day
    if self.kind == "Weekly"
      if self.day_in_week == Time.now.strftime("%a")
        return true
      else
        return false
      end
    else
      return true
    end
  end

  #returns boolean if a weekly task was supposed to be done yesterday; useful for flagging tasks that should have been done
  def delayed_day
    index_yesterday = Time.now.strftime("%w").to_i - 1
    if index_yesterday < 0
      index_yesterday = 6
    end
    abbreviation_array = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
    yesterday = abbreviation_array[index_yesterday]
    if yesterday == self.day_in_week
      return true
    else
      return false
    end
  end

  #following three "completed" methods take a join table entry and return boolean answering title question
  def completed_this_hour?(shifts_task)
    if Time.now.hour == shifts_task.created_at.hour
      return true
    else
      return false
    end
  end

  def completed_today?(shifts_task)
    if Time.now.day == shifts_task.created_at.day
      return true
    else
      return false
    end
  end

  def completed_this_week?(shifts_task)
    if Time.now.strftime("%U") == shifts_task.created_at.strftime("%U")
      return true
    else
      return false
    end
  end

  # returns a hash containing times associated with shifts tasks that were not completed, and the shifts that failed to do them
  def missed_between(start_date, end_date)
    completed_shifts_task = ShiftsTask.find_all_by_task_id(self.id).select{|st| (st.created_at >= start_date) && (st.created_at <= end_date) && !st.missed}
    shifts_at_location = Shift.find_all_by_location_id(self.location_id).select{|s| (s.start >= start_date) && (s.start <= end_date) && (s.submitted?)}

    missed_shifts_tasks_slots = []
    missed_shifts_hash = {}

    if self.kind == "Hourly"
      missed_shifts_tasks_slots = (start_date.to_time..end_date.to_time).step(3600).to_a
    elsif self.kind == "Daily"
      missed_shifts_tasks_slots = (start_date..end_date).to_a
    elsif self.kind == "Weekly"
      missed_shifts_tasks_slots = (start_date..end_date).to_a.select{|d| d.strftime("%a") == self.day_in_week}
    end

    for slot in 0..(missed_shifts_tasks_slots.size - 2)
      guilty_shifts = []
      shifts_tasks_in_slot = completed_shifts_task.select{|st| (st.created_at > missed_shifts_tasks_slots[slot]) && (st.created_at < missed_shifts_tasks_slots[slot + 1])}
      shifts_in_slot = shifts_at_location.select{|s| (s.end > missed_shifts_tasks_slots[slot]) && (s.start < missed_shifts_tasks_slots[slot + 1])}
      shifts_in_slot = shifts_in_slot.delete_if{|s| self.kind != "Hourly" && s.end.seconds_since_midnight < self.time_of_day.seconds_since_midnight }
      if shifts_tasks_in_slot.empty? && !shifts_in_slot.empty?
        guilty_shifts << shifts_in_slot
        guilty_shifts.flatten!
        missed_shifts_hash[missed_shifts_tasks_slots[slot]] = guilty_shifts
      end
    end

    missed_shifts_hash
  end

  private

  def start_less_than_end
   if (self.end.to_i <= self.start.to_i)
    errors.add(:start, "time must be earlier than end time.")
   end
 end

end
