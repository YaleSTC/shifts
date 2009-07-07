class PunchClock < ActiveRecord::Base
  belongs_to :user
  
  def clock_in(in_time = Time.now)
    self.in = in_time
    self.start = self.in
    self.save
  end
  
  def clock_out
    self.out = Time.now
    self.save
  end
  
  def self.find_or_create(user, dept)
    clock = self.find_by_user_id(user.id)
    unless clock
      clock = self.create
      clock.user = user
      clock.department = dept
      clock.save!
    end
    clock
  end
  
  def running
    self.in and !self.out
  end
  
  def time
    self.in ? Time.at(seconds + 60*60*5) : nil
  end
  
  def hours
    (((self.out-self.in) / 3600.0)*100).to_i / 100.0
  end
  
  def date
    self.out.to_date
  end
  
  def h
    time ? time.strftime("%H") : 0
  end
  
  def m
    time ? time.strftime("%M") : 0
  end
  
  def s
    time ? time.strftime("%S") : 0
  end
  
  def time_string
    time ? time.strftime("%H:%M:%S") : "0:0:0"
  end
  
  def seconds
    self.running ? Time.now - self.in : (self.out ? self.out - self.in : 0)
  end
end

