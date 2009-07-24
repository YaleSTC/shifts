class UserProfileEntry < ActiveRecord::Base

  has_one :user_profile_field
  has_one :user

  validates_presence_of :user_id

  def prepare_form_helpers
    display_type = @user_profile_entry.user_profile_field.display_type
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

