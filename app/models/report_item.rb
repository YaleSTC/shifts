class ReportItem < ActiveRecord::Base
  belongs_to :report
  validates_presence_of :content
end
