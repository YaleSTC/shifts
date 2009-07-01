
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
     :conflicts => [],
     :foreign_type_key => "location_source_type",
     :singular_reverse_association_id => :location_source,
     :as => :location_source,
     :foreign_key => "location_source_id",
     :through => :location_sinks_location_sources,
     :is_double => true,
     :from => [:notices,
     :restrictions]
     # called from line 57

  has_many :location_sinks_location_sources_as_location_source,
     :conditions => "location_source_type = 'Location'",
     :dependent => :destroy,
     :as => :location_source,
     :extend => [],
     :class_name => "LocationSinksLocationSource",
     :foreign_key => "location_source_id"
     # called from line 57

  has_many :restrictions,
     :conditions => nil,
     :limit => nil,
     :source => :location_sink,
     :group => nil,
     :source_type => "Restriction",
     :extend => [Location::LocationRestrictionPolymorphicChildAssociationExtension],
     :class_name => "Restriction",
     :through => :location_sinks_location_sources_as_location_source,
     :order => nil
     # called from line 57

  has_many :notices,
     :conditions => nil,
     :limit => nil,
     :source => :location_sink,
     :group => nil,
     :source_type => "Notice",
     :extend => [Location::LocationNoticePolymorphicChildAssociationExtension],
     :class_name => "Notice",
     :through => :location_sinks_location_sources_as_location_source,
     :order => nil
     # called from line 57

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
     :conflicts => [],
     :foreign_type_key => "location_source_type",
     :singular_reverse_association_id => :location_source,
     :as => :location_source,
     :foreign_key => "location_source_id",
     :through => :location_sinks_location_sources,
     :is_double => true,
     :from => [:notices,
     :restrictions]
     # called from line 57

  has_many :location_sinks_location_sources_as_location_source,
     :conditions => "location_source_type = 'Location'",
     :dependent => :destroy,
     :as => :location_source,
     :extend => [],
     :class_name => "LocationSinksLocationSource",
     :foreign_key => "location_source_id"
     # called from line 57

  has_many :restrictions,
     :conditions => nil,
     :limit => nil,
     :source => :location_sink,
     :group => nil,
     :source_type => "Restriction",
     :extend => [Location::LocationRestrictionPolymorphicChildAssociationExtension],
     :class_name => "Restriction",
     :through => :location_sinks_location_sources_as_location_source,
     :order => nil
     # called from line 57

  has_many :notices,
     :conditions => nil,
     :limit => nil,
     :source => :location_sink,
     :group => nil,
     :source_type => "Notice",
     :extend => [Location::LocationNoticePolymorphicChildAssociationExtension],
     :class_name => "Notice",
     :through => :location_sinks_location_sources_as_location_source,
     :order => nil
     # called from line 57

end
