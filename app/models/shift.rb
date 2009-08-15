class Shift < ActiveRecord::Base

  delegate :loc_group, :to => 'location'
  belongs_to :calendar
  belongs_to :repeating_event
  belongs_to :department
  belongs_to :user
  belongs_to :location
  has_one :report, :dependent => :destroy
  has_many :sub_requests, :dependent => :destroy

  validates_presence_of :user
  validates_presence_of :location
  validates_presence_of :start
  validate :is_within_calendar
  before_save :set_active

  named_scope :active, lambda {{:conditions => {:active => true}}}
  named_scope :for_user, lambda {|usr| { :conditions => {:user_id => usr.id }}}
  named_scope :on_day, lambda {|day| { :conditions => ['"start" >= ? and "start" < ?', day.beginning_of_day.utc, day.end_of_day.utc]}}
  named_scope :on_days, lambda {|start_day, end_day| { :conditions => ['"start" >= ? and "start" < ?', start_day.beginning_of_day.utc, end_day.end_of_day.utc]}}
  named_scope :between, lambda {|start, stop| { :conditions => ['"start" >= ? and "start" < ?', start.utc, stop.utc]}}
  named_scope :in_location, lambda {|loc| {:conditions => {:location_id => loc.id}}}
  named_scope :in_locations, lambda {|loc_array| {:conditions => { :location_id => loc_array }}}
  named_scope :scheduled, lambda {{ :conditions => {:scheduled => true}}}
  named_scope :super_search, lambda {|start,stop, incr,locs| {:conditions => ['(("start" >= ? and "start" < ?) or ("end" > ? and "end" <= ?)) and "scheduled" = ? and "location_id" IN (?)', start.utc, stop.utc - incr, start.utc + incr, stop.utc, true, locs], :order => '"location_id", "start"' }}
  named_scope :hidden_search, lambda {|start,stop,day_start,day_end,locs| {:conditions => ['(("start" >= ? and "end" < ?) or ("start" >= ? and "start" < ?)) and "scheduled" = ? and "location_id" IN (?)', day_start.utc, start.utc, stop.utc, day_end.utc, true, locs], :order => '"location_id", "start"' }}

  #TODO: clean this code up -- maybe just one call to shift.scheduled?
  validates_presence_of :end, :if => Proc.new{|shift| shift.scheduled?}
  validates_presence_of :user
  validate :start_less_than_end, :if => Proc.new{|shift| shift.scheduled?}
  validate :shift_is_within_time_slot, :if => Proc.new{|shift| shift.scheduled?}
  validate :user_does_not_have_concurrent_shift, :if => Proc.new{|shift| shift.scheduled?}
  validate_on_create :not_in_the_past, :if => Proc.new{|shift| shift.scheduled?}
  validate :restrictions
  before_save :adjust_sub_requests
  before_save :combine_with_surrounding_shifts

  #
  # Class methods
  #

  def self.delete_part_of_shift(shift, start_of_delete, end_of_delete)
    #Used for taking sub requests
    if !(start_of_delete.between?(shift.start, shift.end) && end_of_delete.between?(shift.start, shift.end))
      raise "You can\'t delete more than the entire shift"
  elsif start_of_delete >= end_of_delete
      raise "Start of the deletion should be before end of deletion"
    elsif start_of_delete == shift.start && end_of_delete == shift.end
      shift.destroy
    elsif start_of_delete == shift.start
      shift.start=end_of_delete
      shift.save!
    elsif end_of_delete == shift.end
      shift.end=start_of_delete
      shift.save!
    else
      later_shift = shift.clone
      later_shift.user = shift.user
      later_shift.location = shift.location
      shift.end = start_of_delete
      later_shift.start = end_of_delete
      shift.save!
      later_shift.save!
      shift.sub_requests.each do |s|
        if s.start >= later_shift.start
          s.shift = later_shift
          s.save!
        end
      end
    end
  end



  #This method creates the multitude of shifts required for repeating_events to work
  #in order to work efficiently, it makes a few GIANT sql insert calls
  def self.make_future(end_date, cal_id, r_e_id, days, loc_id, start_time, end_time, user_id, department_id, active, wipe)
    #We need several inner arrays with one big outer one, b/c sqlite freaks out if the sql insert call is too big
    outer_make = []
    inner_make = []
    outer_test = []
    inner_test = []
    diff = end_time - start_time
    #Take each day and build an array containing the pieces of the sql query
    days.each do |day|
      seed_start_time = start_time.next(day)
        seed_end_time = seed_start_time+diff
      while seed_end_time <= end_date
        if active
          inner_test.push "(user_id = #{user_id.to_sql} AND active = #{true.to_sql} AND department_id = #{department_id.to_sql} AND start <= #{seed_end_time.utc.to_sql} AND end >= #{seed_start_time.utc.to_sql})"
        else
          inner_test.push "(user_id = #{user_id.to_sql} AND calendar_id = #{cal_id.to_sql} AND department_id = #{department_id.to_sql} AND start <= #{seed_end_time.utc.to_sql} AND end >= #{seed_start_time.utc.to_sql})"
        end
        inner_make.push "#{loc_id.to_sql}, #{cal_id.to_sql}, #{r_e_id.to_sql}, #{seed_start_time.utc.to_sql}, #{seed_end_time.utc.to_sql}, #{Time.now.utc.to_sql}, #{Time.now.utc.to_sql}, #{user_id.to_sql}, #{department_id.to_sql}, #{active.to_sql}"
        #Once the array becomes big enough that the sql call will insert 450 rows, start over w/ a new array
        #without this bit, sqlite freaks out if you are inserting a larger number of rows. Might need to be changed
        #for other databases (it can probably be higher for other ones I think, which would result in faster execution)
        if inner_make.length > 450
          outer_make.push inner_make
          inner_make = []
          outer_test.push inner_test
          inner_test = []
        end
         seed_start_time = seed_start_time.next(day)
         seed_end_time = seed_start_time + diff
      end
      #handle leftovers or the case where there are less than 450 rows to be inserted
    end
      outer_make.push inner_make unless inner_make.empty?
      outer_test.push inner_test unless inner_test.empty?
    #for each set of rows to be inserted, insert them, all within a transaction for speed's sake
    if wipe
        outer_test.each do |s|
          Shift.delete_all(s.join(" OR "))
        end
        outer_make.each do |s|
          sql = "INSERT INTO shifts ('location_id', 'calendar_id', 'repeating_event_id', 'start', 'end', 'created_at', 'updated_at', 'user_id', 'department_id', 'active') SELECT #{s.join(" UNION ALL SELECT ")};"
          ActiveRecord::Base.connection.execute sql
        end
      return false
    else
      out = []
        outer_test.each do |s|
          out += Shift.find(:all, :conditions => [s.join(" OR ")])
        end
      if out.empty?
          outer_make.each do |s|
            sql = "INSERT INTO shifts ('location_id', 'calendar_id', 'repeating_event_id', 'start', 'end', 'created_at', 'updated_at', 'user_id', 'department_id', 'active') SELECT #{s.join(" UNION ALL SELECT ")};"
            ActiveRecord::Base.connection.execute sql
          end
        return false
      end
      return out.collect{|t| "The shift for "+t.to_message_name+" conflicts. Use wipe to fix."}.join(",")
    end
  end

  def self.check_for_conflicts(shifts, wipe)
    big_array = []
    while shifts && !shifts.empty? do
      big_array.push shifts[0..450]
      shifts = shifts[451..shifts.length]
    end
    if big_array.empty?
      ""
    elsif wipe
      big_array.each do |sh|
        Shift.delete_all([sh.collect{|s| "(user_id = #{s.user_id.to_sql} AND active = #{true.to_sql} AND department_id = #{s.department_id.to_sql} AND start <= #{s.end.utc.to_sql} AND end >= #{s.start.utc.to_sql})"}.join(" OR ")])
      end
      return ""
    else
      out=big_array.collect do |sh|
        Shift.find(:all, :conditions => [sh.collect{|s| "(user_id = #{s.user_id.to_sql} AND active = #{true.to_sql} AND department_id = #{s.department_id.to_sql} AND start <= #{s.end.utc.to_sql} AND end >= #{s.start.utc.to_sql})"}.join(" OR ")]).collect{|t| "The shift for "+t.to_message_name+"."}.join(",")
      end
      out.join(",")+","
    end
  end

  # ==================
  # = Object methods =
  # ==================

  def duration
    self.end - self.start
  end

  def css_class(current_user = nil)
    if current_user and self.user == current_user
      css_class = "user"
    else
      css_class = "shift"
    end
    if missed?
      css_class += "_missed"
    elsif (signed_in? ? report.arrived : Time.now) > start + department.department_config.grace_period*60 #seconds
      css_class += "_late"
    end
    css_class
  end

  def too_early?
    self.start > 30.minutes.from_now
  end

  def missed?
    self.has_passed? and !self.signed_in?
  end

  def late?
    self.signed_in? && (self.report.arrived - self.start > $department.department_config.grace_period*60)
    #seconds
  end

  #a shift has been signed in to if it has a report
  def signed_in?
    self.report && !self.report.departed
  end

  #a shift has been signed in to if its shift report has been submitted
  def submitted?
    self.report and self.report.departed
  end

  #TODO: subs!
  #check if a shift has a *pending* sub request and that sub is not taken yet
  def has_sub?
    #note: if the later part of a shift has been taken, self.sub still returns true so we also need to check self.sub.new_user.nil?
    !self.sub_requests.empty? #and sub.new_user.nil? #new_user in sub is only set after sub is taken.  shouldn't check new_shift bcoz a shift can be deleted from db. -H
  end

  def has_passed?
    self.end < Time.now
  end

  def has_started?
    self.start < Time.now
  end

  # If new shift runs up against another compatible shift, combine them and save,
  # preserving the earlier shift's information
  def combine_with_surrounding_shifts
    if (shift_later = Shift.find(:first, :conditions => {:start => self.end, :user_id => self.user_id, :location_id => self.location_id, :calendar_id => self.calendar.id}))
      self.end = shift_later.end
      shift_later.sub_requests.each { |s| s.shift = self }
      shift_later.destroy
      self.save!
    end
    if (shift_earlier = Shift.find(:first, :conditions => {:end => self.start, :user_id => self.user_id, :location_id => self.location_id, :calendar_id => self.calendar.id}))
      self.start = shift_earlier.start
      shift_earlier.sub_requests.each {|s| s.shift = self}
      shift_earlier.destroy
      self.save!
    end
  end

  def exceeds_max_staff?
    count = 0
    shifts_in_period = []
    Shift.find(:all, :conditions => {:location_id => self.location_id, :scheduled => true}).each do |shift|
      shifts_in_period << shift if (self.start..self.end).overlaps?(shift.start..shift.end) && self.end != shift.start && self.start != shift.end
    end
    increment = self.department.department_config.time_increment
    time = self.start + (increment / 2)
    while (self.start..self.end).include?(time)
      concurrent_shifts = 0
      shifts_in_period.each do |shift|
        concurrent_shifts += 1 if (shift.start..shift.end).include?(time)
      end
      count = concurrent_shifts if concurrent_shifts > count
      time += increment
    end
    count + 1 > self.location.max_staff
  end


  # ===================
  # = Display helpers =
  # ===================
  def short_display
     self.location.short_name + ', ' + self.start.to_s(:just_date) + ' ' + self.time_string
  end

  def to_message_name
    self.user.name + " in " + self.location.short_name + " from " + self.start.to_s(:am_pm_long_no_comma) + " to " + self.end.to_s(:am_pm_long_no_comma) + " on " + self.calendar.name
  end

  def short_name
    self.location.short_name + ', ' + self.user.name + ', ' + self.time_string + ", " + self.start.to_s(:just_date)
  end

  def time_string
    self.scheduled? ? self.start.to_s(:am_pm) + '-' + self.end.to_s(:am_pm) : "unscheduled"
  end

  def sub_request
    SubRequest.find_by_shift_id(self.id)
  end

  private

  # ======================
  # = Validation helpers =
  # ======================
  def restrictions
    unless self.power_signed_up
      self.user.restrictions.each do |restriction|
        if restriction.max_hours
          relevant_shifts = Shift.between(restriction.starts,restriction.expires).for_user(self.user)
          hours_sum = relevant_shifts.map{|shift| shift.end - shift.start}.flatten.sum / 3600.0
          hours_sum += (self.end - self.start) / 3600.0
          if hours_sum > restriction.max_hours
            errors.add(:max_hours, "have been exceeded by #{hours_sum - restriction.max_hours}.")
          end
        end
      end
      self.location.restrictions.each do |restriction|
        if restriction.max_hours
          relevant_shifts = Shift.between(restriction.starts,restriction.expires).in_location(self.location)
          hours_sum = relevant_shifts.map{|shift| shift.end - shift.start}.flatten.sum / 3600.0
          hours_sum += (self.end - self.start) / 3600.0
          if hours_sum > restriction.max_hours
            errors.add(:max_hours, "have been exceeded by #{hours_sum - restriction.max_hours}.")
          end
        end
      end
    end
  end

  def start_less_than_end
    errors.add(:start, "must be earlier than end time") if (self.end < start)
  end

  def shift_is_within_time_slot
    unless self.power_signed_up
      c = TimeSlot.count(:all, :conditions => ['location_id = ? AND start <= ? AND end >= ? AND active = ?', self.location_id, self.start, self.end, true])
      errors.add_to_base("You can only sign up for a shift during a time slot!") if c == 0
    end
  end

  def user_does_not_have_concurrent_shift

    c = Shift.count(:all, :conditions => ['user_id = ? AND start < ? AND end > ? AND department_id =? AND (active = ? OR calendar_id = ?)', self.user_id, self.end, self.start, self.department, true, self.calendar])
    unless c.zero?
      errors.add_to_base("#{self.user.name} has an overlapping shift in that period") unless (self.id and c==1)
    end

  end

  def not_in_the_past
    errors.add_to_base("Can't sign up for a shift that has already passed!") if self.start <= Time.now
  end

  #TODO: remove sub.save! repalce with sub.save and catch exceptions
  def adjust_sub_requests
    self.sub_requests.each do |sub|
      if sub.start > self.end || sub.end < self.start
        sub.destroy
      else
        sub.start = self.start if sub.start < self.start
        sub.mandatory_start = self.start if sub.mandatory_start < self.start
        sub.end = self.end if sub.end > self.end
        sub.mandatory_end = self.end if sub.mandatory_end > self.end
        sub.save!
      end
    end
  end

  def set_active
      self.active = self.calendar.active
      return true
  end

  def is_within_calendar
    unless self.calendar.default
      errors.add_to_base("Repeating event start and end dates must be within the range of the calendar!") if self.start < self.calendar.start_date || self.end > self.calendar.end_date
    end
  end


  class << columns_hash['start']
    def type
      :datetime
    end
  end
end
