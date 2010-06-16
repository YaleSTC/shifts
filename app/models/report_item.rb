require 'socket'

class ReportItem < ActiveRecord::Base
  belongs_to :report
  delegate :user, :to => 'report.shift'
  validates_presence_of :content, :report_id

  define_index do
    # fields
    indexes content

    # attributes
    has created_at, updated_at
    has report.shift.start, :as => :shift_start
    has report.shift(:id), :as => :shift_id
  end
  
  before_save :check_for_ip_address_change
  
  def content_with_formatting
    content.sanitize_and_format
  end
  
  def check_for_ip_address_change
    #if ip has changed from previous line item, note this
    previous_report_items = self.report.report_items
    hostname = Socket::getaddrinfo(self.ip_address, nil)[0][2]
    hostname = hostname == self.ip_address ? nil : (" (" + hostname + ") ") #Don't include the hostname if it is the same as IP address (usually this is returned if no hostname is available)
    self.content += " [IP Address changed to #{self.ip_address}#{hostname}]" if ( !previous_report_items.empty? and previous_report_items.last.ip_address != self.ip_address)
  end
end