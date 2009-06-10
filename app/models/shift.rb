class Shift < ActiveRecord::Base

  delegate :loc_group, :to => 'location'
  delegate :department, :to => 'location'

  belongs_to :user
  belongs_to :location
  has_one :report, :dependent => :destroy

  has_many :sub_requests, :dependent => :destroy

  delegate :loc_group, :to => 'location'
  delegate :department, :to => 'location'

  validates_presence_of :user
  validates_presence_of :location
  validates_presence_of :start

  #validate :a_bunch_of_shit

  #TODO: clean this code up -- maybe just one call to shift.scheduled?
  validates_presence_of :end, :if => Proc.new{|shift| shift.scheduled?}
  validate :start_less_than_end, :if => Proc.new{|shift| shift.scheduled?}
  validate :user_does_not_have_concurrent_shift, :if => Proc.new{|shift| shift.scheduled?}
  validate_on_create :not_in_the_past, :if => Proc.new{|shift| shift.scheduled?}

  #
  # Class methods
  #

  def self.combine_with_surrounding_shifts(shift)
    # if new shift runs up against another compatible shift, combine them and save,
    # preserving the earlier shift's information
    if (shift_later = Shift.find(:first, :conditions => {:start => shift.end, :user_id => shift.user_id, :location_id => shift.location_id}))
      shift.end = shift_later.end
      shift_later.destroy
      shift.save
    end
    if (shift_earlier = Shift.find(:first, :conditions => {:end => shift.start, :user_id => shift.user_id, :location_id => shift.location_id}))
      shift_earlier.end = shift.end
      shift.destroy
      shift_earlier.save
      shift = shift_earlier
    end
    shift
  end

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

  def too_early?
    self.start > 30.minutes.from_now
  end

  def missed?
    self.has_passed? and !self.signed_in?
  end

  def late?
    #TODO: tie this to an actual admin preference
    self.signed_in? && (self.report.start - self.start > 7)
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
    self.sub_requests #and sub.new_user.nil? #new_user in sub is only set after sub is taken.  shouldn't check new_shift bcoz a shift can be deleted from db. -H
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


  # ===================
  # = Display helpers =
  # ===================
  def short_display
     self.location.short_name + ', ' + self.start.to_s(:just_date) + ' ' + self.start.to_s(:am_pm) + '-' + self.end.to_s(:am_pm)
  end

  def short_name
    time_string = self.scheduled? ? self.start.to_s(:am_pm) + '-' + self.end.to_s(:am_pm) : "unscheduled"

    self.location.short_name + ', ' + self.user.name + ', ' + self.start.to_s(:am_pm) + '-' + self.end.to_s(:am_pm) + ", " + self.start.to_s(:just_date)
  end



  private

  # ======================
  # = Validation helpers =
  # ======================
  def start_less_than_end
    errors.add(:start, "must be earlier than end time") if (self.end < start)
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
end
