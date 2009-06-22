class Location < ActiveRecord::Base
  belongs_to :loc_group

  has_many :time_slots
  has_many :shifts
  has_and_belongs_to_many :data_objects
  

  validates_presence_of :loc_group
  validates_presence_of :name
  validates_presence_of :short_name
  validates_numericality_of :max_staff
  validates_numericality_of :min_staff
  validates_numericality_of :priority

  validates_uniqueness_of :name, :scope => :loc_group_id
  validates_uniqueness_of :short_name, :scope => :loc_group_id
  validate :max_staff_greater_than_min_staff

  delegate :department, :to => :loc_group

  def max_staff_greater_than_min_staff
    errors.add("The minimum number of staff cannot be larger than the maximum.", "") if (self.min_staff > self.max_staff)
  end
  
  def admin_permission
    self.loc_group.admin_permission
  end
end

