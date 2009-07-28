class UserProfileEntry < ActiveRecord::Base

  has_one :user_profile_field
  belongs_to :user_profile

  def field_name
    field_name = UserProfileField.find(self.user_profile_field_id).name
  end

  def display_type
    display_type = UserProfileField.find(self.user_profile_field_id).display_type
  end

  def making_form
    if display_type == "text_field"
      return ["user_profile_fields", id, {:id => id}]
    elsif display_type == "text_area"
      return ["user_profile_fields", id]
    elsif display_type == "select"
      options = values.split(',').each{|opt| opt.squish!}
      return ["user_profile_fields", id, options.map{|opt| [opt, opt]}]
    elsif display_type == "check_box"
      options = values.split(',').each{|opt| opt.squish!}
      return options.map{|v| ["user_profile_fields[#{id}]", v]}
    elsif display_type == "radio_button"
      options = values.split(',').each{|opt| opt.squish!}
      return options.map{|v| ["user_profile_fields[#{id}]", 1, v]}
    end
  end

end

