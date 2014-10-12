# == Schema Information
#
# Table name: restrictions
#
#  id         :integer          not null, primary key
#  starts     :datetime
#  expires    :datetime
#  max_subs   :integer
#  max_hours  :decimal(10, 2)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Restriction < ActiveRecord::Base
  belongs_to :department

  has_and_belongs_to_many :locations
  has_and_belongs_to_many :loc_groups
  has_and_belongs_to_many :users

  validates_presence_of :starts, :expires
  validates_presence_of :max_hours,  unless: :max_subs, message: "and Max subs can't both be blank"
  attr_accessor :start_date
  attr_accessor :start_time
  attr_accessor :end_date
  attr_accessor :end_time
  before_validation :join_date_and_time


  scope :current, -> {where("starts <= ? and expires >= ?", Time.now, Time.now)}
  # Need to make Restriction connect with locations (and users) in the same way
  # that Notices and Locations/LocGroups are connected
  # def users
  #   self.user_sources.collect{|s| s.users}.flatten.uniq
  # end

  # def locations
  #   self.location_sources.collect{|s| s.locations}.flatten.uniq
  # end

  def join_date_and_time
    self.starts ||= self.start_date.to_date.to_time + self.start_time.seconds_since_midnight
    self.expires ||= self.end_date.to_date.to_time + self.end_time.seconds_since_midnight
  end

end

