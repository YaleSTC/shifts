
class LocationSinksLocationSource

  belongs_to :location_sink,
     :polymorphic => true
     # called from line 57

  belongs_to :location_source,
     :polymorphic => true
     # called from line 57

  acts_as_double_polymorphic_join ,
     :location_sources => [:departments,
     :loc_groups,
     :locations],
     :location_sinks => [:notices,
     :restrictions]
     # called from line 57

end
