class Restriction < ActiveRecord::Base
  belongs_to :department

  validates_presence_of :starts, :expires
  
  validates_presence_of :max_hours,  :unless => :max_subs, :message => "and Max subs can't both be blank"

  named_scope :current, lambda {{ :conditions => ["#{:start.to_sql_column} <= #{Time.now.to_sql} and #{:expires.to_sql_column} >= #{Time.now.to_sql}"]}}

  def users
    self.user_sources.collect{|s| s.users}.flatten.uniq
  end
  
  def locations
    self.location_sources.collect{|s| s.locations}.flatten.uniq
  end

end
