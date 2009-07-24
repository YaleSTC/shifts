class ReportItem < ActiveRecord::Base
  belongs_to :report
  delegate :user, :to => 'report.shift'
  validates_presence_of :content
  
  def content_with_formatting
    content.sanitize_and_format
  end
end
