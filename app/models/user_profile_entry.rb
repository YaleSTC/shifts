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
      return ["user_profile_entries[#{id}]", :content, {value: content}]
    elsif display_type == "picture_link"
      return ["user_profile_entries[#{id}]", :content, {value: content}]
    elseif display_type == "upload_pic"
      return ["user_profile_entries[#{id}]", :content, {value: content}]
    elsif display_type == "text_area"
      return ["user_profile_entries[#{id}]", :content, {value: content}]
    elsif display_type == "select"
      options = values.split(',').collect{|opt| opt.squish}
      return ["user_profile_entries[#{id}]", :content, options.map{|opt| [opt, opt]}, {selected: content}]
    elsif display_type == "check_box"
      options = values.split(',').collect{|opt| opt.squish}
      chosen = content.split(',').collect{|opt| opt.squish}
      if content
        return options.map{|v| ["user_profile_entries[#{id}]", v, chosen.include?(v) ? {checked: true} : {}]}
      else
        return options.map{|v| ["user_profile_entries[#{id}]", v]}
      end
    elsif display_type == "radio_button"
      options = values.split(',').collect{|opt| opt.squish}
      return options.map{|v| ["user_profile_entries[#{id}]", :content, v, content==v ? {checked: true} : {}]}
    end
  end

end

