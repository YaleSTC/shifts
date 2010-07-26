class Sticky < Notice
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
