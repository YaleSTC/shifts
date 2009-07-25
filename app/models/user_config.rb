class UserConfig < ActiveRecord::Base
  belongs_to :user

  validates_presence_of   :user_id
  validates_uniqueness_of :user_id

  VIEW_WEEK_OPTIONS = [
    # Displayed               stored in db
    ["Whole week",      "whole_period"],
    ["Remainder of week",   "remainder"],
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
  # def view_loc_groups
  #   read_attribute(:view_loc_groups).split(', ').map{|lg|LocGroup.find(lg)}
  # end

  # if default_dept is not specified, returns first department;
  # but if the user does not belong to any department, returns nil
  def default_department
    Department.find_by_id(default_dept) || (user.departments.empty? ? nil : user.departments.first)
  end

def prepare_form_helpers
    if display_type == "text_field"
      return ["data_fields", id, {:id => id}]
    elsif display_type == "text_area"
      return ["data_fields", id]
    elsif display_type == "select"
      options = values.split(',').each{|opt| opt.squish!}
      return ["data_fields", id, options.map{|opt| [opt, opt]}]
    elsif display_type == "check_box"
      options = values.split(',').each{|opt| opt.squish!}
      return options.map{|v| ["data_fields[#{id}]", v]}
    elsif display_type == "radio_button"
      options = values.split(',').each{|opt| opt.squish!}
      return options.map{|v| ["data_fields[#{id}]", 1, v]}
    end
  end

end

