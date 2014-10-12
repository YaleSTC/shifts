# == Schema Information
#
# Table name: data_objects
#
#  id           :integer          not null, primary key
#  data_type_id :integer
#  name         :string(255)
#  description  :string(255)
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

class DataObject < ActiveRecord::Base
  has_and_belongs_to_many :locations
  belongs_to :data_type
  has_many :data_entries, dependent: :destroy

  delegate :department, to: :data_type

  validates_presence_of   :name
  validates_presence_of   :data_type_id
  validates_presence_of   :locations
  validates_uniqueness_of :name, scope: :data_type_id

  def self.by_location_group(loc_group)
    loc_group.locations.map{|loc| loc.data_objects}.flatten.compact
  end

  ### Virtual Attributes ###

  def data_fields
    self.data_type.data_fields
  end

end

