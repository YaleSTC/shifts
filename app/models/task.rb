class Task < ActiveRecord::Base
  has_many :shifts_tasks
  has_many :shifts, :through => :shifts_tasks
  belongs_to :location
  
  validates_presence_of :name, :kind
  validate :start_less_than_end
  
  named_scope :active, lambda {{:conditions => {:active => true}}}
  named_scope :after_now, lambda {{:conditions => ["#{:end} >= #{Time.now.utc.to_sql}"]}}
  named_scope :in_locations, lambda {|loc_array| {:conditions => { :location_id => loc_array }}}
  named_scope :in_location, lambda {|location| {:conditions => { :location_id => location }}}
  named_scope :hourly, lambda {{:conditions => {:kind => "Hourly"}}}
  named_scope :daily, lambda {{:conditions => {:kind => "Daily"}}}
  named_scope :weekly, lambda {{:conditions => {:kind => "Weekly"}}}
  named_scope :after_time, lambda { |time| {:conditions => ["time > ?", time]}}
  named_scope :between, lambda {|start, stop| { :conditions => ["#{:start.to_sql_column} >= #{start.utc.to_sql} and #{:start.to_sql_column} < #{stop.utc.to_sql}"]}}
  
  #done shifts are crossed out in their locations
  def done
    @last_completion = ShiftsTask.all.select{|st| st.task_id == self.id}.last
    if @last_completion
      if (self.kind == "Hourly") && completed_this_hour?(@last_completion)
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
  
  #delayed tasks show up as bold in their locations
  def needs_doing
    @last_completion = ShiftsTask.all.select{|st| st.task_id == self.id}.last
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
  
  #returns boolean if now is after scheduled time for task today; does not respect designated days for weekly tasks
  def right_time
    scheduled_time = self.time_of_day.seconds_since_midnight
    now_time = Time.now.seconds_since_midnight
    seconds_past_scheduled = now_time - scheduled_time
    if seconds_past_scheduled > 0
      return true
    elsif self.kind == "Hourly" #not extactly valid interpretation, since hourly tasks shouldn't have a time_of_day; to prevent nil value errors
      return true
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
  
  # returns an array containing times when a task could have been completed by an active shift but was not
  def missed_between(start_date, end_date)
    interval_completed_shifts_task = ShiftsTask.find_all_by_task_id(self.id).select{|st| st.created_at >= start_date && st.created_at <= end_date}
    shifts_at_location = Shift.find_all_by_location_id(self.location_id).select{|s| s.start > start_date && s.start < end_date && s.submitted?}
    
    missed_shifts_tasks_slots = []
    
    if self.kind == "Hourly"
      missed_shifts_tasks_slots = (start_date.to_time..end_date.to_time).step(3600).to_a
    elsif self.kind == "Daily"
      missed_shifts_tasks_slots = (start_date..end_date).to_a
    elsif self.kind == "Weekly"
      missed_shifts_tasks_slots = (start_date..end_date).to_a.select{|d| d.strftime("%a") == self.day_in_week}
    end
    
    for slot in 0..(missed_shifts_tasks_slots.size - 2)
      if !interval_completed_shifts_task.select{|st| st.created_at > missed_shifts_tasks_slots[slot] && st.created_at < missed_shifts_tasks_slots[slot + 1]}.empty?
        missed_shifts_tasks_slots[slot] = "done"
      elsif shifts_at_location.select{|s| s.start > missed_shifts_tasks_slots[slot] || s.end < missed_shifts_tasks_slots[slot + 1]}.empty?
        missed_shifts_tasks_slots[slot] = "no_shifts"
      end
    end
    
    return missed_shifts_tasks_slots.delete_if{|s| s == "done" || s == "no_shifts"}
    
  end
  
  private
  
  def start_less_than_end
    errors.add(:start, "time must be earlier than end time.") if (self.end <= start)
  end
end