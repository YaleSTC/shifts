class Notice < ActiveRecord::Base

  belongs_to  :author,
              :class_name => "User"

  belongs_to :remover,
              :class_name => "User"

  belongs_to :department

  has_many :viewer_links, :class_name => "UserSourceLink", :as => :user_sink

  has_many :display_location_links, :class_name => "LocationSourceLink", :as => :location_sink

  validates_presence_of :content
  validate :presence_of_locations_or_viewers
  validate_on_create :proper_time

#  def for_user_names
#    names = []
#    self.for_users.split(',').each do |user_id|
#      names.push User.find_by_id(user_id.to_i).name
#    end
#    names.join(", ")
#  end

#  def locations(get_objects = false)
#    array = self.for_locations.split(",").map &:to_i
#    array = Location.find(array) if get_objects
#    array
#  end

#  def locations=(array)
#    array ||= []
#    array.map! &:id if array.first.class == Location
#    self.for_locations = array.join " "
#  end

#  def location_groups(get_objects = false)
#    array = self.for_location_groups.split(",").map &:to_i
#    array = LocGroup.find(array) if get_objects
#    array
#  end

#  def location_groups=(array)
#    array ||= []
#    array.map! &:id if array.first.class == LocGroup
#    self.for_location_groups = array.join " "
#  end

#  def process_for_users
#    temp_users = []
#    self.for_users.split(",").map(&:strip).each do |user_string|
#      user = User.find_by_login(user_string) || User.find_by_name(user_string)
#      if user
#        temp_users << user.id
#      else
#        self.errors.add "contains \'#{user_string}\'. Could not find user by that name or netid" unless user_string.blank?
#      end
#    end
#    self.for_users = temp_users.join(',')
#  end

  def display_for
    display_for = []
    display_for.push "for users #{self.viewers.collect{|n| n.name}.join(", ")}" unless self.viewers.empty?
    display_for.push "for locations #{self.display_locations.collect{|l| l.short_name}.join(", ")}" unless self.display_locations.empty?
    display_for.join "<br/>"
  end

  def self.current
    #TODO: this could be much cleaner.  once we get beyond a few hundred notices,
    #      the speed of this degrades really fast. should be moved to database logic.
    #      Something like this: Notice.find(:all, :conditions => ['start_time < ? AND end_time > ?', Time.now, Time.now]).sort_by{|note| note.is_sticky ? 1 : 0}
    Notice.all.select{|n| n.is_current?}.sort_by{|note| note.is_sticky ? 1 : 0}
  end

  def add_viewer_source(source)
      viewer_link = UserSourceLink.new
      viewer_link.user_source = source
      viewer_link.user_sink = self
      viewer_link.save!
  end

  def viewers
    self.viewer_links.collect{|l| l.user_source.users}.flatten.uniq
  end

  def remove_all_viewer_sources
    UserSourceLink.delete_all(:user_sink_id => self.id)
  end

  def add_display_location_source(source)
      display_location_link = LocationSourceLink.new
      display_location_link.location_source = source
      display_location_link.location_sink = self
      display_location_link.save!
  end

  def display_locations
    self.display_location_links.collect{|l| l.location_source.locations}.flatten.uniq
  end

  def remove_all_display_location_sources
    LocationSourceLink.delete_all(:location_sink_id => self.id)
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

  def self.inactive
    inactive_notices = []
    Notice.all.each {|n| inactive_notices << n unless n.is_current?}
    inactive_notices
  end

  private
  #Validations
  def presence_of_locations_or_viewers
    errors.add_to_base "Your notice must display somewhere or for someone." if self.display_locations.empty? && self.viewers.empty?
  end

  def proper_time
    errors.add_to_base "Start/end time combination is invalid." if self.start_time > self.end_time if self.end_time || Time.now > self.end_time if self.end_time
  end
end

