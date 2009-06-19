class Notice < ActiveRecord::Base

  belongs_to  :author,
              :class_name => "User"

  belongs_to :remover,
              :class_name => "User"

  belongs_to :department

  has_many :viewer_links, :class_name => "UserSourceLink", :as => :user_sink

  has_many :display_location_links, :class_name => "LocationSourceLink", :as => :location_sink

  validates_presence_of :content
  validate :proper_time, :presence_of_locations_or_loc_groups

#  def for_user_names
#    names = []
#    self.for_users.split(',').each do |user_id|
#      names.push User.find_by_id(user_id.to_i).name
#    end
#    names.join(", ")
#  end

  def display_for
    display_for = []
    display_for.push "for users #{self.viewers.collect{|n| n.name}.join(", ")}" unless self.viewers.empty?
    display_for.push "for locations #{self.display_locations.collect{|l| l.short_name}.join(", ")}" unless self.display_locations.empty?
    display_for.join "<br/>"
  end

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

  def self.current
    current_notices = []
    Notice.all.each {|n| current_notices << n if n.is_current?}
    current_notices
  end

  def add_viewer_source(source)
      viewer_link = UserSourceLink.new
      viewer_link.user_source = source
      viewer_link.user_sink = self
      viewer_link.save!
  end

  def viewers
    viewers = []
#    if link.user_source
     self.viewer_links.each do |link|
       viewers += link.user_source.users
#     end
    end
    viewers.uniq
  end

  def add_display_location_source(source)
      display_location_link = LocationSourceLink.new
      display_location_link.location_source = source
      display_location_link.location_sink = self
      display_location_link.save!
  end

  def display_locations
    display_locations = []
    self.display_location_links.each do |link|
      display_locations += link.location_source.locations
    end
   display_locations.uniq
  end

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

  def presence_of_locations_or_loc_groups
    errors.add_to_base("Your notice must display somehwere or for someone.") if self.display_locations.empty? && self.viewers.empty?
  end

  def proper_time
    errors.add_to_base("Start/end time combination is invalid.") if self.start_time > self.end_time || Time.now > self.end_time unless self.end_time.nil?
  end

  def is_current?
    if self.end_time.nil?
      Time.now > self.start_time
    else
      Time.now > self.start_time && Time.now < self.end_time
    end
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

end

