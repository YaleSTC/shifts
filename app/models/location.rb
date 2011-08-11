class Location < ActiveRecord::Base
  belongs_to :loc_group

  named_scope :active, :conditions => {:active => true}
  named_scope :in_group, 
    lambda {|loc_group,*order| {
      :conditions => {:loc_group_id => loc_group.id},
      :order => order.flatten.first || 'priority ASC'                                  
  }}

  has_many :time_slots
	has_many :template_time_slots
  has_many :shifts
	has_many :locations_requested_shifts
	has_many :requested_shifts, :through => :locations_requested_shifts
  has_many :locations_shift_preferences
	has_many :shift_preferences, :through => :locations_shift_preferences
  has_and_belongs_to_many :data_objects
	has_and_belongs_to_many :requested_shifts

  validates_presence_of :loc_group
  validates_presence_of :name
  validates_presence_of :description
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
		return self.announcements + self.stickies
#   ActiveRecord::Base.transaction do
#       a = LocationSinksLocationSource.find(:all, :conditions => ["location_sink_type = 'Notice' AND location_source_type = 'Location' AND location_source_id = #{self.id.to_sql}"]).collect(&:location_sink_id)
#       b = Sticky.active.collect(&:id)
#       c = Announcement.active.collect(&:id)
#       Notice.find(a & (b + c))
#     end

  end

  def stickies
     ActiveRecord::Base.transaction do
        a = LocationSinksLocationSource.find(:all, :conditions => ["location_sink_type = 'Notice' AND location_source_type = 'Location' AND location_source_id = #{self.id.to_sql}"]).collect(&:location_sink_id)
        b = Sticky.active.collect(&:id)
        Sticky.find(a & b).sort_by{|s| s.start}
      end
  end

  def announcements
     ActiveRecord::Base.transaction do
        a = LocationSinksLocationSource.find(:all, :conditions => ["location_sink_type = 'Notice' AND location_source_type = 'Location' AND location_source_id = #{self.id.to_sql}"]).collect(&:location_sink_id)
        b = Announcement.active.collect(&:id)
        Announcement.find(a & b).sort_by{|a| a.start}
      end
  end

  def links
     ActiveRecord::Base.transaction do
        a = LocationSinksLocationSource.find(:all, :conditions => ["location_sink_type = 'Notice' AND location_source_type = 'Location' AND location_source_id = #{self.id.to_sql}"]).collect(&:location_sink_id)
        b = Link.active.collect(&:id)
        Link.find(a & b) 
      end
  end

  def restrictions #TODO: this could probalby be optimized
    Restriction.current.select{|r| r.locations.include?(self)}
  end
  
  def deactivate
    self.active = false
    self.save!
    #Location activation must be set prior to individual shift activation; Shift class before_save
    shifts.after_date(Time.now.utc).update_all :active => false
  end
  
  def activate
    self.active = true
    self.save!
    #Location activation must be set prior to individual shift activation; Shift class before_save
    @shifts = shifts.after_date(Time.now.utc)
    @shifts.each do |shift|
      if shift.user.is_active?(shift.department) && shift.calendar.active
        shift.active = true
      end
      shift.save
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
  
  def is_staffed_in_list?(shift_list, time)
    time = time.in_time_zone
    remaining_shifts = shift_list.select{|s| s.start <= time && s.end >= time && !s.missed?}
    return remaining_shifts == [] ? false : true
  end
  
  def shifts_between(start_time, end_time)
    shifts = Shift.find(:all, :conditions => ["start >= #{start_time.to_sql} AND end <= #{end_time.to_sql} AND location_id = #{self.id.to_sql}"])
  end
  
  def summary_stats(start_date, end_date)
    shifts_set = shifts.on_days(start_date, end_date).active
    summary_stats = {}
    
    summary_stats[:start_date] = start_date
    summary_stats[:end_date] = end_date
    summary_stats[:total] = shifts_set.size
    summary_stats[:late] = shifts_set.select{|s| s.late == true}.size
    summary_stats[:missed] = shifts_set.select{|s| s.missed == true}.size
    summary_stats[:left_early] = shifts_set.select{|s| s.left_early == true}.size
    
    return summary_stats
  end
    
  def detailed_stats(start_date, end_date)
    shifts_set = shifts.on_days(start_date, end_date).active
    detailed_stats = {}
  
    shifts_set.each do |s|
       stat_entry = {}
       stat_entry[:id] = s.id
       stat_entry[:shift] = s.short_display
       stat_entry[:in] = s.created_at
       stat_entry[:out] = s.updated_at

       if s.missed
         stat_entry[:notes] = "Missed"
       elsif s.late && s.left_early
         stat_entry[:notes] = "Late and left early"
       elsif s.late
         stat_entry[:notes] = "Late"
       elsif s.left_early
         stat_entry[:notes] = "Left early"
       else
         stat_entry[:notes]
       end
       stat_entry[:missed] = s.missed
       stat_entry[:late] = s.late
       stat_entry[:left_early] = s.left_early
       stat_entry[:updates_hour] = s.updates_hour
       detailed_stats[s.id] = stat_entry
    end
    
    return detailed_stats
  end
  
  protected

  def max_staff_greater_than_min_staff
    errors.add("The minimum number of staff cannot be larger than the maximum.", "") if (self.min_staff and self.max_staff and self.min_staff > self.max_staff)
  end
  
end

