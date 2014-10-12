# == Schema Information
#
# Table name: data_types
#
#  id            :integer          not null, primary key
#  name          :string(255)
#  description   :text
#  department_id :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

class DataType < ActiveRecord::Base
  belongs_to :department
  has_many :data_objects, dependent: :destroy
  has_many :data_fields, dependent: :destroy
  accepts_nested_attributes_for :data_fields, 
    reject_if: proc {|attrs| attrs.reject{|k,v| k == "display_type"}.all? {|k, v| v.blank? }}

  
  validates_uniqueness_of :name
  validates_presence_of   :name
  validates_presence_of   :department_id
  
  def data_field_attributes=(data_field_attributes)
    data_field_attributes.each do |attributes|
      data_fields.build(attributes)
    end
  end
  
  
  after_update :save_data_fields

  def new_data_field_attributes=(data_field_attributes)
    data_field_attributes.each do |data_field|
      temp = data_fields.build(data_field)
      temp.data_type = self
    end
  end

  def existing_data_field_attributes=(data_field_attributes)
    data_fields.reject(&:new_record?).each do |data_field|
      attributes = data_field_attributes[data_field.id.to_s]
      if attributes
        data_field.attributes = attributes
      else
        data_fields.delete(data_field)
      end
    end
  end

  def save_data_fields
    data_fields.each do |data_field|
      data_field.save(validate: false)
    end
  end
end

