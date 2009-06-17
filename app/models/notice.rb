class Notice < ActiveRecord::Base

  has_and_belongs_to_many :LocGroup

  validates_presence_of :content
  validate :process_for_users

  def locations(get_objects = false)
    array = self.for_locations.split.map &:to_i
    array = Location.find(array) if get_objects
    array
  end

  def locations=(array)
    array ||= []
    array.map! &:id if array.first.class == Location
    self.for_locations = array.join " "
  end

  def location_groups(get_objects = false)
    array = self.for_location_groups.split.map &:to_i
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
    for_users.split(",").map(&:strip).each do |user_string|
      user = User.find_by_login(user_string) || User.find_by_name(user_string)
      if user
        temp_users << user.id
      else
        self.errors.add "contains \'#{user_string}\'. Could not find user by that name or netid" unless user_string.blank?
      end
    end
    self.for_users = temp_users.join(',')
  end

  def is_current?
    return Time.now > self.start_time && Time.now < self.end_time
  end

  def is_upcoming?
    return Time.now < self.start_time
  end

end

