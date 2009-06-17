class Report < ActiveRecord::Base
  belongs_to :shift
  delegate :user, :to => :shift
  has_many :report_items, :dependent => :destroy

  validates_uniqueness_of :shift_id
end
