class Calendar < ActiveRecord::Base
  has_many :shifts
  has_many :time_slots
  belongs_to :department
  
  validates_presence_of :name
  validates_presence_of :start_date
  validates_presence_of :end_date, :if => Proc.new{|calendar| !calendar.default?}
  
  validates_uniqueness_of :name, :scope => :department_id
end