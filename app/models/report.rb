class Report < ActiveRecord::Base
  belongs_to :shift
  has_many :report_items
end
