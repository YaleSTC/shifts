class Shift < ActiveRecord::Base
  belongs_to :user
  belongs_to :location
  has_one :report
  
  validates_presence_of :user
  validates_presence_of :location
  validates_presence_of :start
  validates_presence_of :end
  
  validate :start_less_than_end
  validate :user_does_not_have_concurrent_shift
  validate :shift_has_nonzero_length
  validate :not_in_the_past
  
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
  end
  
  
  # ==================
  # = Object methods =
  # ==================

  def has_passed?
    self.end < Time.now
  end

  def has_started?
    self.start < Time.now
  end
  
  
  private
  
  # ======================
  # = Validation helpers =
  # ======================
  def start_less_than_end
    errors.add(:start, "must be earlier than end time") if (self.end < start)
  end
  
  def user_does_not_have_concurrent_shift
    #unless self.start == self.end  #allow users to sign into blank report even if they have an overlapping shift
    c = Shift.count(:all, :conditions => ['user_id = ? AND start < ? AND end > ?', self.user_id, self.end, self.start])
    unless c.zero?
      errors.add_to_base("#{self.user.name} has an overlapping shift in that period") unless (self.id and c==1)
    end
    #end
  end
  
  def shift_has_nonzero_length
    # this prevents the error case where:
    # 1) a user creates a shift
    # 2) that shift is edited to conflict with another shift, with length 0
    # 3) that shift can then be edited again to any length, conflicting with the other shift
    errors.add_to_base("A shift's start and end time cannot be the same") if (self.start == self.end)
  end
  
  def not_in_the_past
    errors.add_to_base("Can't sign up for a time slot that has already passed!") if self.end < Time.now
  end
end
