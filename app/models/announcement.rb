class Announcement < Notice

  scope :active, -> {where("start <= ? AND end is ? OR end > ?", Time.now.utc, nil, Time.now.utc) }
  scope :upcoming, -> {where("start > ?", Time.now.utc)}
  scope :ordered_by_start, order('start')

  def active?
    self.start <= Time.now && (self.end == nil || self.end > Time.now)
  end

end
