class UserConfig < ActiveRecord::Base
  belongs_to :user

  validates_presence_of   :user_id
  validates_uniqueness_of :user_id

  VIEW_WEEK_OPTIONS = [
    # Displayed               stored in db
    ["Whole week",            "whole_period"],
    ["Remainder of week",     "remainder"],
    ["Just the current day",  "current_day"]
  ]

### CUSTOM ACCESSORS ###
# Incidentally, these two are identical, but I don't know where I could refactor
# them out to.  So they're not DRY for now. We can improve it later, once we
# come up with a good place to do so. -ben

  def watched_data_objects=(data_objects)
    data_objects = data_objects.split(',') if data_objects.class == String
    write_attribute(:watched_data_objects, data_objects.uniq.remove_blank.join(", "))
  end

  # Loc Groups can be assigned either by passing in an array
  # of ids or a comma-separated string.
  def view_loc_groups=(loc_groups)
    loc_groups = loc_groups.split(', ') if loc_groups.class == String
    write_attribute(:view_loc_groups, loc_groups.uniq.remove_blank.join(", "))
  end

  def view_loc_groups
    read_attribute(:view_loc_groups).nil? ? user.loc_groups(default_department) : read_attribute(:view_loc_groups).split(', ').map{|lg|LocGroup.find(lg)} && user.loc_groups(default_department)
  end

  # if default_dept is not specified, returns first department;
  # but if the user does not belong to any department, returns nil
  def default_department
    Department.find_by_id(default_dept) || (user.departments.empty? ? nil : user.departments.first)
  end

end

