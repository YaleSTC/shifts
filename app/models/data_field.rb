# == Schema Information
#
# Table name: data_fields
#
#  id           :integer          not null, primary key
#  data_type_id :integer
#  name         :string(255)
#  display_type :string(255)
#  values       :string(255)
#  upper_bound  :float
#  lower_bound  :float
#  exact_alert  :string(255)
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  active       :boolean          default(TRUE)
#

class DataField < ActiveRecord::Base
  # options for select; these are the allowable data field display types
  DISPLAY_TYPE_OPTIONS = {"Text Field"   => "text_field",
                          "Paragraph Text"    => "text_area",
                          "Select from a List"   => "select",
                          "Multiple Choice" => "radio_button",
                          "Check Boxes" => "check_box"}

  belongs_to :data_type

  validates_presence_of :data_type
  validates_presence_of :name
  validates_presence_of :display_type

  validates_uniqueness_of :name, scope: :data_type_id

  default_scope where(active: true)

  #This should probably be moved to the data_entries helper
  #Based on the display type, returns the arguments for the formhelper methods
  def prepare_form_helpers
    if display_type == "text_field"
      return ["data_fields", id, {id: id}]
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

  #We want to have the default scope on data fields only include active
  #This method allows us to bypass the default scope when we are potentially
  #interacting with historical data. In that case, we want to find destroyed
  #data fields as well.
  def self.find_with_destroyed *args
    self.with_exclusive_scope { find(*args) }
  end

  def check_alerts?(string)
    if string == self.exact_alert
      return false
    elsif self.lower_bound && string.to_f < self.lower_bound
      return false
    elsif self.upper_bound && string.to_f > self.upper_bound
      return false
    else
      return true
    end
  end

end

