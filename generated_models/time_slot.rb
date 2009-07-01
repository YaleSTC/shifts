
class TimeSlot

  belongs_to ,
     locatio
     # called from line 57

  has_many :shifts,
     :through => :location
     # called from line 57

end
