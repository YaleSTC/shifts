class PunchClock < ActiveRecord::Base
  belongs_to :user
  belongs_to :department
  belongs_to :punch_clock_set
  
  validates_presence_of :user
  validate_on_create :conflicting_shifts_or_clocks?
  
  def running_time
    no_of_sec = self.paused ? self.runtime : (Time.now - self.last_touched + runtime)
    [no_of_sec/3600, no_of_sec/60 % 60, no_of_sec % 60].map{|t| t.to_i.to_s.rjust(2, '0')}.join(':')
  end
  
private
  
  def conflicting_shifts_or_clocks?
    if self.user and self.user.current_shift
      errors.add_to_base("You are already signed in to a shift.")
    elsif self.user and self.user.punch_clock
      errors.add_to_base("You already have an active punch clock.")
    end
  end
end

