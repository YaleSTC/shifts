class Location < ActiveRecord::Base
  belongs_to :loc_group

  named_scope :active, :conditions => {:active => true}
  named_scope :in_group, 
    lambda {|loc_group,*order| {
      :conditions => {:loc_group_id => loc_group.id},
      :order => order.flatten.first || 'priority ASC'                                  
  }}

  has_many :time_slots
  has_many :shifts
  has_and_belongs_to_many :data_objects

  validates_presence_of :loc_group
  validates_presence_of :name
  validates_presence_of :short_name
  validates_presence_of :min_staff
  validates_numericality_of :max_staff
  validates_numericality_of :min_staff
  validates_numericality_of :priority

  validates_uniqueness_of :name, :scope => :loc_group_id
  validates_uniqueness_of :short_name, :scope => :loc_group_id
  validate :max_staff_greater_than_min_staff

  delegate :department, :to => :loc_group

  def admin_permission
    self.loc_group.admin_permission
  end

  def locations
    [self]
  end

  def current_notices
    Notice.active.select {|n| n.locations.include?(self)}
  end

  def current_links
    Notice.active_links.select {|n| n.locations.include?(self)}
  end

  def stickys
    self.notices.select {|n| n.sticky}
  end

  def announcements
    self.notices.select {|n| n.announcement}
  end

  def links
    self.current_links.select {|n| n.useful_link}
  end

  def restrictions #TODO: this could probalby be optimized
    Restriction.current.select{|r| r.locations.include?(self)}
  end
  
  def deactivate
    self.active = false
    self.save!
    #Location activation must be set prior to individual shift activation; Shift class before_save
    shifts = Shift.in_location(self).select{|s| s.start > Time.now}
    shifts.each do |shift|
      shift.active = false
      shift.save!
    end
  end
  
  def activate
    self.active = true
    self.save!
    #Location activation must be set prior to individual shift activation; Shift class before_save
    shifts = Shift.in_location(self).select{|s| s.start > Time.now}
    shifts.each do |shift|
      if shift.user.is_active?(shift.department) && shift.calendar.active
        shift.active = true
      else
        shift.active = false
      end
      shift.save!
    end    
  end

  def count_people_for(shift_list, min_block)
    people_count = {}
    people_count.default = 0
    unless shift_list.nil?
      shift_list.each do |shift|
        t = shift.start
        while (t<shift.end)
          people_count[t.to_s(:am_pm)] += 1
          t += min_block
        end
      end
    end
    people_count
  end

  protected

  def max_staff_greater_than_min_staff
    errors.add("The minimum number of staff cannot be larger than the maximum.", "") if (self.min_staff and self.max_staff and self.min_staff > self.max_staff)
  end
  
end

