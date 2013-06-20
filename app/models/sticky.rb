class Sticky < Notice
  
  scope :ordered_by_start, :order => 'start'
    
  def active?
    self.end == nil || self.end > Time.now
  end
  
	EXPIRE_ON = [
    ["day",  "day"],
    ["week", "week"],
		["month", "month"]
  ]

end
