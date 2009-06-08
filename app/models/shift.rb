class Shift < ActiveRecord::Base
  belongs_to :location

  delegate :loc_group, :to => 'location'
  delegate :department, :to => 'location'
end

