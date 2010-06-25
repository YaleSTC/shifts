class Restriction < ActiveRecord::Base
  belongs_to :department

  validates_presence_of :starts, :expires
  validates_presence_of :max_hours,  :unless => :max_subs, :message => "and Max subs can't both be blank"
  attr_accessor :start_date
  attr_accessor :start_time
  attr_accessor :end_date
  attr_accessor :end_time

  named_scope :current, lambda {{ :conditions => ["#{:starts.to_sql_column} <= #{Time.now.to_sql} and #{:expires.to_sql_column} >= #{Time.now.to_sql}"]}}

  def users
    self.user_sources.collect{|s| s.users}.flatten.uniq
  end

  def locations
    self.location_sources.collect{|s| s.locations}.flatten.uniq
  end

end
