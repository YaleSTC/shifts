class Announcement < Notice
  
  named_scope :upcoming, lambda {{ :conditions => ["start > ?", Time.now.utc]}}
  named_scope :ordered_by_start, :order => 'start'

  def active?
    self.start <= Time.now && (self.end == nil || self.end > Time.now)
  end

end
