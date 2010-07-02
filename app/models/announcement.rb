class Announcement < Notice
  named_scope :active, lambda {{ :conditions => ["start_time <= ? AND end_time = ? OR end_time > ?", Time.now.utc, nil, Time.now.utc] }}
  named_scope :upcoming, lambda {{ :conditions => ["start_time > ?", Time.now.utc]}}


end
