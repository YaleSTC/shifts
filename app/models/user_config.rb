class UserConfig < ActiveRecord::Base
  belongs_to :user
  
  validates_presence_of   :user_id
  validates_uniqueness_of :user_id
  
  VIEW_WEEK_OPTIONS = [
    # Displayed               stored in db
    ["Whole pay period",      "whole_period"],
    ["Remainder of period",   "remainder"],
    ["Just the current day",  "current_day"]
  ]
  
  # Custom accessor, so you can assign loc groups by passing in either an array
  # of ids or a comma-separated string.
  def view_loc_groups=(loc_groups)
    loc_groups = loc_groups.split(', ') if loc_groups.class == String
    write_attribute(:view_loc_groups, loc_groups.uniq.remove_blank.join(", "))
  end
  
  # Currently deprecated because I'm not sure if it's a good idea -ben
  # Returns an array of loc groups, rather than the databse comma-sep string
#  def view_loc_groups
#    read_attribute(:view_loc_groups).split(', ').map{|lg|LocGroup.find(lg)}
#  end

end
