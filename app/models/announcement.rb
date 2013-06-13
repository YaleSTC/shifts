class Announcement < Notice
  has_many :location_associations, :as => :postable
  has_many :locations, :through => :location_associations
  has_many :loc_group_associations, :as => :postable
  has_many :loc_groups, :through => :loc_group_associations

  named_scope :active, lambda {{ :conditions => ["start <= ? AND end is ? OR end > ?", Time.now.utc, nil, Time.now.utc] }}
  named_scope :upcoming, lambda {{ :conditions => ["start > ?", Time.now.utc]}}
  named_scope :ordered_by_start, :order => 'start'

  def active?
    self.start <= Time.now && (self.end == nil || self.end > Time.now)
  end

end
