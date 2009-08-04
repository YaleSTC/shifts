class UserProfileEntry < ActiveRecord::Base

  belongs_to :user_profile_field
  belongs_to :user_profile

  def field_name
    field_name = UserProfileField.find(self.user_profile_field_id).name
  end

  def display_type
    display_type = UserProfileField.find(self.user_profile_field_id).display_type
  end

  def values
    values = UserProfileField.find(self.user_profile_field_id).values
  end

  def prepare_form_helpers
    if display_type == "text_field"
      return ["user_profile_entries[#{id}]", id, {:value => content}]
    elsif display_type == "text_area"
      return ["user_profile_entries[#{id}]", id, {:id => id, :value => content}]
    elsif display_type == "select"
      options = values.split(',').each{|opt| opt.squish!}
      return ["user_profile_entries[#{id}]", id, options.map{|opt| [opt, opt]}, {:selected => content}]
    elsif display_type == "check_box"
      options = values.split(',').each{|opt| opt.squish!}
      return options.map{|v| ["user_profile_entries[#{id}]", v, v.include?(content) ? {v => '', :checked => true} : {v => ''}]}
    elsif display_type == "radio_button"
      options = values.split(',').each{|opt| opt.squish!}
      return options.map{|v| ["user_profile_entries[#{id}]", 1, v, v==content ? {v => '', :checked => true} : {v => ''}]}
    end
  end

end

