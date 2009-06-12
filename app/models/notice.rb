class Notice < ActiveRecord::Base

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

end

