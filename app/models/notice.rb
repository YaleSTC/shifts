class Notice < ActiveRecord::Base

  belongs_to  :author,
              :class_name => "User",
              :foreign_key => "author_id"

  validates_presence_of :content
  validate :process_for_users, :proper_time, :presence_of_locations_or_loc_groups

  def for_user_names
    names = []
    self.for_users.split(',').each do |user_id|
      names.push User.find_by_id(user_id.to_i).name
    end
    names.join(", ")
  end

  def auth_full_list
    result = []
    result.push "for users #{self.for_user_names}" unless self.for_users.empty?
    locations = []
    self.locations(true).each do |loc|
      locations.push loc.short_name
    end
    result.push "for location #{locations.join(", ")}"
    location_groups = []
    self.location_groups(true).each do |lg|
      location_groups.push lg.name unless lg.nil?
    end
    result.push "for location group #{location_groups.join(", ")}"
    result.join "<br/>"
  end

  def locations(get_objects = false)
    array = self.for_locations.split(",").map &:to_i
    array = Location.find(array) if get_objects
    array
  end

  def locations=(array)
    array ||= []
    array.map! &:id if array.first.class == Location
    self.for_locations = array.join " "
  end

  def location_groups(get_objects = false)
    array = self.for_location_groups.split(",").map &:to_i
    array = LocGroup.find(array) if get_objects
    array
  end

  def location_groups=(array)
    array ||= []
    array.map! &:id if array.first.class == LocGroup
    self.for_location_groups = array.join " "
  end

  def process_for_users
    temp_users = []
    self.for_users.split(",").map(&:strip).each do |user_string|
      user = User.find_by_login(user_string) || User.find_by_name(user_string)
      if user
        temp_users << user.id
      else
        self.errors.add "contains \'#{user_string}\'. Could not find user by that name or netid" unless user_string.blank?
      end
    end
    self.for_users = temp_users.join(',')
  end

  def presence_of_locations_or_loc_groups
    self.errors add "You must add a location or location group" if self.for_locations.nil? && self.for_location_groups.nil?
  end

  def proper_time
    errors.add "Start/end time" if self.start_time > self.end_time || Time.now > self.end_time unless self.end_time.nil?
  end

  def is_current?
    return Time.now > self.start_time && Time.now < self.end_time
  end

  def is_upcoming?
    return Time.now < self.start_time
  end

end

