class Announcement < Notice
  scope :active, lambda {{ :conditions => ["start <= ? AND end is ? OR end > ?", Time.now.utc, nil, Time.now.utc] }}
  scope :upcoming, lambda {{ :conditions => ["start > ?", Time.now.utc]}}
  scope :ordered_by_start, :order => 'start'

  def active?
    self.start <= Time.now && (self.end == nil || self.end > Time.now)
  end

end
