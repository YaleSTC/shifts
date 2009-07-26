class UserProfileField < ActiveRecord::Base
  has_many :user_profile_entries
  has_one :department

  validates_presence_of :department_id
  validates_presence_of :display_type
  validates_presence_of :values

  DISPLAY_TYPE_OPTIONS = {"Text Field"   => "text_field",
                          "Paragraph Text"    => "text_area",
                          "Select from a List"   => "select",
                          "Multiple Choice" => "radio_button",
                          "Check Boxes" => "check_box"}

end

