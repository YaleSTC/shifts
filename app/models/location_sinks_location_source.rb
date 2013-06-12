# Commented out because we have no more need for doubly polymorphic joins 
=begin
class LocationSinksLocationSource < ActiveRecord::Base
  belongs_to :location_sink,   :polymorphic => true
  belongs_to :location_source, :polymorphic => true
  
  acts_as_double_polymorphic_join(:location_sources => [:departments,:loc_groups, :locations],
                                  :location_sinks   => [:notices, :restrictions])
end
=end
