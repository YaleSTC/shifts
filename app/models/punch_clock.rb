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
  
  def pause
    self.paused = true
    self.runtime += Time.now - self.last_touched
    self.last_touched = Time.now
    return "Successfully paused clock."
  end
  
  def unpause
    self.paused = false
    self.last_touched = Time.now
    return "Successfully unpaused clock."
  end  
  
  def submit(description = "Punch clock for #{self.user}")
    self.pause unless self.paused?
    self.save
    payform_item = PayformItem.new({:date => Date.today,
                                  :category => Category.find_by_name("Punch Clocks"),
                                  :hours => (self.runtime/3600.0), # sec -> hr
                                  :description => description})
    payform_item.payform = Payform.build(self.department, self.user, Date.today)
    begin
      return nil if payform_item.save! && self.destroy       
    rescue Exception => e
      return e.message
    end
  end
    
private
  
  def conflicting_shifts_or_clocks?
    if self.user and self.user.current_shift || self.user.punch_clock
      errors.add("Someone is already signed in to a shift or punch clock")
    end
  end
  
  
end

