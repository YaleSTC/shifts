class Notice < ActiveRecord::Base

  belongs_to :author, :class_name => "User"
  belongs_to :remover, :class_name => "User"
  belongs_to :department

  validate :presence_of_locations_and_viewers, :proper_time
	validates_presence_of :content
  
  before_destroy :destroy_user_sinks_user_sources

  named_scope :inactive, lambda {{ :conditions => ["#{:end_time.to_sql_column} <= #{Time.now.utc.to_sql}"] }}
  named_scope :active_with_end, lambda {{ :conditions => ["#{:start_time.to_sql_column} <= #{Time.now.utc.to_sql} and #{:end_time.to_sql_column} > #{Time.now.utc.to_sql}"]}}
  named_scope :active_without_end, lambda {{ :conditions => ["#{:start_time.to_sql_column} <= #{Time.now.utc.to_sql} and #{:indefinite.to_sql_column} = #{true.to_sql}"]}}
  named_scope :upcoming, lambda {{ :conditions => ["#{:start_time.to_sql_column} > #{Time.now.utc.to_sql}"]}}

  def self.active
    (Announcement.active_with_end + Announcement.active_without_end).uniq.sort_by{|n| n.start_time} +
    (Sticky.active_with_end + Sticky.active_without_end).uniq.sort_by{|n| n.start_time}
  end

	def active
		self.start_time < Time.now && (self.end_time > Time.now if self.end_time)
	end

  def self.active_links
    (self.links.active_with_end + self.links.active_without_end).uniq
  end

  def display_for
    display_for = []
    display_for.push "for users #{self.users.collect{|n| n.name}.to_sentence}" unless self.users.empty?
    display_for.push "for locations #{self.locations.collect{|l| l.short_name}.to_sentence}" unless self.locations.empty?
    display_for.join "<br/>"
  end

  def is_current?
    self.end_time ? self.start_time < Time.now && self.end_time > Time.now : self.start_time < Time.now
  end

  def is_upcoming?
    return self.start_time > Time.now if self.start_time
    false
  end

  def is_sticky
    self.sticky
  end

  def viewers
    self.user_sources.collect{|us| us.users}.flatten.uniq
  end

  def display_locations
    self.location_sources.collect{|ls| ls.locations}.flatten.uniq
  end

  def remove(user)
    self.errors.add_to_base "This notice has already been removed by #{remover.name}" and return if self.remover && self.end_time
    self.end_time = Time.now
    self.indefinite = false
    self.remover = user
    true if self.save
  end
  
  def content_with_formatting
    content.sanitize_and_format
  end

  private
  #Validations
  def presence_of_locations_and_viewers
    if self.location_sources.empty? && self.user_sources.empty?
			errors.add_to_base "Your #{self.class.name.downcase} must display somewhere."
  	end
	end

  def proper_time
    errors.add_to_base "Start/end time combination is invalid." if self.start_time >= self.end_time if self.end_time
  end
  
  def destroy_user_sinks_user_sources
    UserSinksUserSource.delete_all("#{:user_sink_type.to_sql_column} = #{"Notice".to_sql} AND #{:user_sink_id.to_sql_column} = #{self.id.to_sql}")
  end
end

