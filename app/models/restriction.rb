class Restriction < ActiveRecord::Base
  belongs_to :department
  has_many :user_sinks_user_sources, :as => :user_sink
  
  has_many :departments, :through => :user_sinks_user_sources, :source => :department,
                         :conditions => "user_sinks_user_sources.user_source_type = 'Department'"

end
