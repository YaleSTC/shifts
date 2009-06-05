class Report < ActiveRecord::Base
  belongs_to :shift
  has_many :report_items
  
  validates_uniqueness_of :shift_id
end
