class Notice < ActiveRecord::Base

  belongs_to :author, :class_name => "User"
  belongs_to :remover, :class_name => "User"
  belongs_to :department

  validate :content_or_label, :presence_of_locations_and_viewers, :proper_time
  before_destroy :destroy_user_sinks_user_sources
  
  named_scope :in_department, lambda { |dept| {:conditions => {:department_id => dept}}}
  named_scope :created_by, lambda { |user| {:conditions => {:author_id => user}}}
  named_scope :inactive, lambda {{ :conditions => ["end_time != ? AND end_time < ?", nil, Time.now.utc] }}
  named_scope :not_link, :conditions => ["type != ?", "Link"]
  
  def self.active_links
     Link.active
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
			errors.add_to_base "Your #{self.class.name.downcase} must display somewhere"
  	end
	end

  def proper_time
    errors.add_to_base "Start/end time combination is invalid." if self.start_time >= self.end_time if self.end_time
  end
  
  def destroy_user_sinks_user_sources
    UserSinksUserSource.delete_all("#{:user_sink_type.to_sql_column} = #{"Notice".to_sql} AND #{:user_sink_id.to_sql_column} = #{self.id.to_sql}")
  end

	def content_or_label
		if self.content.blank?
			if self.type == "Link"
				errors.add_to_base "Your link must have a label"
			else
				errors.add_to_base "Your #{self.type.downcase} must have content"
			end
		end
	end
end

