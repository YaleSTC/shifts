class Notice < ActiveRecord::Base

  belongs_to  :author,
              :class_name => "User"

  belongs_to :remover,
              :class_name => "User"

  belongs_to :department

  validates_presence_of :content
  validate :presence_of_locations_or_viewers
  validate_on_create :proper_time

  def display_for
    display_for = []
    display_for.push "for users #{self.viewers.collect{|n| n.name}.join(", ")}" unless self.viewers.empty?
    display_for.push "for locations #{self.display_locations.collect{|l| l.short_name}.join(", ")}" unless self.display_locations.empty?
    display_for.join "<br/>"
  end

  def self.active
    Notice.all.select{|n| n.is_current?}.sort_by{|note| note.is_sticky ? 1 : 0}
  end

  def self.inactive
    Notice.all.select{|n| !n.is_current?}.sort_by{|note| note.is_sticky ? 1 : 0}
  end

  def viewers
    self.user_sources.collect{|s| s.users}.flatten.uniq
  end

  def display_locations
    self.location_sources.collect{|s| s.locations}.flatten.uniq
  end

  def is_current?
    self.end_time.nil? ? Time.now > self.start_time : Time.now > self.start_time && Time.now < self.end_time
  end

  def is_upcoming?
    return Time.now < self.start_time
  end

  def remove(user)
    self.errors.add_to_base "This notice has already been removed by #{remover.name}" and return if self.remover && self.end_time
    self.end_time = Time.now
    self.remover = user
    true
  end

  private
  #Validations
  def presence_of_locations_or_viewers
    errors.add_to_base "Your notice must display somewhere or for someone." if self.display_locations.empty? && self.viewers.empty? && !self.new_record?
  end

  def proper_time
    errors.add_to_base "Start/end time combination is invalid." if self.start_time > self.end_time if self.end_time || Time.now > self.end_time if self.end_time
  end
end

