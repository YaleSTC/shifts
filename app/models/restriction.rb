class Restriction < ActiveRecord::Base
  belongs_to :department


  def users
    self.user_sources.collect{|s| s.users}.flatten.uniq
  end

end
