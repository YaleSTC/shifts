class Calendar < ActiveRecord::Base
  has_many :shifts
  has_many :timeslots
end
