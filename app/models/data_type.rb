class DataType < ActiveRecord::Base
  belongs_to :department
  has_many :data_objects, :dependent => :destroy
  has_many :data_fields, :dependent => :destroy
  accepts_nested_attributes_for :data_fields, 
    :reject_if => proc {|attrs| attrs.reject{|k,v| k == "display_type"}.all? {|k, v| v.blank? }}

  
  validates_uniqueness_of :name
  validates_presence_of   :name
  validates_presence_of   :department_id
end

