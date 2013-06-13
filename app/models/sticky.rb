class Sticky < Notice
  has_many :location_associations, :as => :postable
  has_many :locations, :through => :location_associations
  has_many :loc_group_associations, :as => :postable
  has_many :loc_groups, :through => :loc_group_associations

  named_scope :active, lambda {{ :conditions => ["end is ? OR end > ?", nil, Time.now.utc] }}
  named_scope :ordered_by_start, :order => 'start'
    
  def active?
    self.end == nil || self.end > Time.now
  end
  
	EXPIRE_ON = [
    ["day",  "day"],
    ["week", "week"],
		["month", "month"]
  ]

end
