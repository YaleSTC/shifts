
class Location

  belongs_to ,
     loc_grou
     # called from line 57

  has_many ,
     time_slot
     # called from line 57

  has_many ,
     shift
     # called from line 57

  has_and_belongs_to_many ,
     data_object
     # called from line 57

  has_many_polymorphs :location_sinks,
     :foreign_key => "location_source_id",
     :foreign_type_key => "location_source_type",
     :singular_reverse_association_id => :location_source,
     :as => :location_source,
     :through => :location_sinks_location_sources,
     :is_double => true,
     :conflicts => [],
     :from => [:notices,
     :restrictions]
     # called from line 57

  has_many :location_sinks_location_sources_as_location_source,
     :foreign_key => "location_source_id",
     :conditions => "location_source_type = 'Location'",
     :dependent => :destroy,
     :as => :location_source,
     :extend => [],
     :class_name => "LocationSinksLocationSource"
     # called from line 57

  has_many :notices,
     :conditions => nil,
     :limit => nil,
     :source_type => "Notice",
     :source => :location_sink,
     :group => nil,
     :through => :location_sinks_location_sources_as_location_source,
     :order => nil,
     :extend => [Location::LocationNoticePolymorphicChildAssociationExtension],
     :class_name => "Notice"
     # called from line 57

  has_many :restrictions,
     :conditions => nil,
     :limit => nil,
     :source_type => "Restriction",
     :source => :location_sink,
     :group => nil,
     :through => :location_sinks_location_sources_as_location_source,
     :order => nil,
     :extend => [Location::LocationRestrictionPolymorphicChildAssociationExtension],
     :class_name => "Restriction"
     # called from line 57

end
