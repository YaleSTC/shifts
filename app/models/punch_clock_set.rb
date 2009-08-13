class PunchClockSet < ActiveRecord::Base
  has_many :punch_clocks

  validates_presence_of :description
  validates_length_of   :description, :minimum => 10

  def users
    self.punch_clocks.map{|pc| pc.users}.flatten
  end

  def running_time
    no_of_sec = Time.now - self.created_at
    [ no_of_sec / 3600, no_of_sec / 60 % 60, no_of_sec % 60 ].map{ |t| t.to_i.to_s.rjust(2, '0') }.join(':')
  end
end
