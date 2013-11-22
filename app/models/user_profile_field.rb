class UserProfileField < ActiveRecord::Base
  has_many :user_profile_entries, dependent: :destroy
  has_one :department

  validates_presence_of :department_id
  validates_presence_of :display_type

  DISPLAY_TYPE_OPTIONS = {"Text Field"   => "text_field",
                          "Paragraph Text"    => "text_area",
                          "Select from a List"   => "select",
                          "Multiple Choice" => "radio_button",
                          "Check Boxes" => "check_box",
                          "Profile Picture (hyperlink)" => "picture_link"
                          }

  DISPLAY_TYPE_VIEW = {"text_field"   => "Text Field",
                        "text_area"    => "Paragraph Text",
                        "select"   => "Select from a List",
                        "radio_button" => "Multiple Choice",
                        "check_box" => "Check Boxes",
                        "picture_link" => "Profile Picture (hyperlink)"
                          }

end

