class Shift < ActiveRecord::Base

  delegate :loc_group, :to => 'location'
  delegate :department, :to => 'location'

  belongs_to :user
  belongs_to :location
  has_one :report, :dependent => :destroy
  has_many :sub_requests, :dependent => :destroy

  validates_presence_of :user
  validates_presence_of :location
  validates_presence_of :start

  named_scope :on_day, lambda {|day| { :conditions => ['start >= ? and start < ?', day.beginning_of_day.utc, day.end_of_day.utc]}}
  named_scope :in_location, lambda {|loc| {:conditions => ['location_id = ?', loc.id]}}
  named_scope :scheduled, lambda {{ :conditions => {:scheduled => true}}}
  
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

  # ==================
  # = Object methods =
  # ==================

  def css_class(current_user = nil)
    if current_user and user == current_user
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
    self.report
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
  #
  # def has_sub_at_start?
  #   has_sub? and start == sub.start
  # end


  def has_passed?
    self.end < Time.now
  end

  def has_started?
    self.start < Time.now
  end

  # If new shift runs up against another compatible shift, combine them and save,
  # preserving the earlier shift's information
  def combine_with_surrounding_shifts
    if (shift_later = Shift.find(:first, :conditions => {:start => self.end, :user_id => self.user_id, :location_id => self.location_id}))
      self.end = shift_later.end
      shift_later.sub_requests.each { |s| s.shift = self }
      shift_later.destroy
      self.save!
    end
    if (shift_earlier = Shift.find(:first, :conditions => {:end => self.start, :user_id => self.user_id, :location_id => self.location_id}))
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

  def short_name
    self.location.short_name + ', ' + self.user.name + ', ' + self.time_string + ", " + self.start.to_s(:just_date)
  end

  def time_string
    self.scheduled? ? self.start.to_s(:am_pm) + '-' + self.end.to_s(:am_pm) : "unscheduled"
  end


  private

  # ======================
  # = Validation helpers =
  # ======================
  def restrictions
    #location_restrictions = location.restrictions
    #user_restrictions = user.restrictions
    #TODO: RESTRICTIONS NEEDED TO BE FIXED - REMOVED CODE FOR NOW
  end

  def start_less_than_end
    errors.add(:start, "must be earlier than end time") if (self.end < start)
  end

  def shift_is_within_time_slot
    unless self.power_signed_up
      c = TimeSlot.count(:all, :conditions => ['location_id = ? AND start <= ? AND end >= ?', self.location_id, self.start, self.end])
      errors.add_to_base("You can only sign up for a shift during a time slot!") if c == 0
    end
  end

  def user_does_not_have_concurrent_shift

    c = Shift.count(:all, :conditions => ['user_id = ? AND start < ? AND end > ?', self.user_id, self.end, self.start])
    unless c.zero?
      errors.add_to_base("#{self.user.name} has an overlapping shift in that period") unless (self.id and c==1)
    end

  end

  def not_in_the_past
    errors.add_to_base("Can't sign up for a time slot that has already passed!") if self.start <= Time.now
  end

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


  class << columns_hash['start']
    def type
      :datetime
    end
  end
end

