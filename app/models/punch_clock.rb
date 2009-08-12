class PunchClock < ActiveRecord::Base
  belongs_to :user
  belongs_to :department
  belongs_to :punch_clock_set
  
  validates_presence_of :user
  validate :conflicting_shifts_or_clocks?
  
  def running_time
    no_of_sec = Time.now - self.created_at
    [ no_of_sec / 3600, no_of_sec / 60 % 60, no_of_sec % 60 ].map{ |t| t.to_i.to_s.rjust(2, '0') }.join(':')
  end
  
private
  
  def conflicting_shifts_or_clocks?
    if self.user and self.user.current_shift || self.user.punch_clock
      errors.add("Someone is already signed in to a shift or punch clock")
    end
  end
  
  
end

