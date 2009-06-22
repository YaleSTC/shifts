class ReportItem < ActiveRecord::Base
  belongs_to :report
  delegate :user, :to => 'report.shift'
  validates_presence_of :content
end
