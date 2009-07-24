class Restriction < ActiveRecord::Base
  belongs_to :department


  def users
    self.user_sources.collect{|s| s.users}.flatten.uniq
  end
  
  def locations
    self.location_sources.collect{|s| s.locations}.flatten.uniq
  end

end
