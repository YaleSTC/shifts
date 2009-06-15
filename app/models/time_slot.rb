class TimeSlot < ActiveRecord::Base
  belongs_to :location
  has_many :shifts, :through => :location



  private


end
