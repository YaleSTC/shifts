class Sticky < Notice
  named_scope :active, lambda {{ :conditions => ["end_time = ? OR end_time > ?", nil, Time.now.utc] }}
  
	EXPIRE_ON = [
    ["day",  "day"],
    ["week", "week"],
		["month", "month"]
  ]

end
