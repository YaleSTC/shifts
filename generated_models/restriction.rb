
class Restriction

  belongs_to ,
     departmen
     # called from line 57

  has_many_polymorphs :location_sources,
     :foreign_key => "location_sink_id",
     :foreign_type_key => "location_sink_type",
     :singular_reverse_association_id => :location_sink,
     :as => :location_sink,
     :through => :location_sinks_location_sources,
     :is_double => true,
     :conflicts => [],
     :from => [:departments,
     :loc_groups,
     :locations]
     # called from line 57

  has_many :location_sinks_location_sources_as_location_sink,
     :foreign_key => "location_sink_id",
     :conditions => "location_sink_type = 'Restriction'",
     :dependent => :destroy,
     :as => :location_sink,
     :extend => [],
     :class_name => "LocationSinksLocationSource"
     # called from line 57

  has_many :departments,
     :conditions => nil,
     :limit => nil,
     :source_type => "Department",
     :source => :location_source,
     :group => nil,
     :through => :location_sinks_location_sources_as_location_sink,
     :order => nil,
     :extend => [Restriction::RestrictionDepartmentPolymorphicChildAssociationExtension],
     :class_name => "Department"
     # called from line 57

  has_many :loc_groups,
     :conditions => nil,
     :limit => nil,
     :source_type => "LocGroup",
     :source => :location_source,
     :group => nil,
     :through => :location_sinks_location_sources_as_location_sink,
     :order => nil,
     :extend => [Restriction::RestrictionLocGroupPolymorphicChildAssociationExtension],
     :class_name => "LocGroup"
     # called from line 57

  has_many :locations,
     :conditions => nil,
     :limit => nil,
     :source_type => "Location",
     :source => :location_source,
     :group => nil,
     :through => :location_sinks_location_sources_as_location_sink,
     :order => nil,
     :extend => [Restriction::RestrictionLocationPolymorphicChildAssociationExtension],
     :class_name => "Location"
     # called from line 57

  has_many_polymorphs :user_sources,
     :foreign_key => "user_sink_id",
     :foreign_type_key => "user_sink_type",
     :singular_reverse_association_id => :user_sink,
     :as => :user_sink,
     :through => :user_sinks_user_sources,
     :is_double => true,
     :conflicts => [],
     :from => [:departments,
     :roles,
     :users]
     # called from line 57

  has_many :user_sinks_user_sources_as_user_sink,
     :foreign_key => "user_sink_id",
     :conditions => "user_sink_type = 'Restriction'",
     :dependent => :destroy,
     :as => :user_sink,
     :extend => [],
     :class_name => "UserSinksUserSource"
     # called from line 57

  has_many :departments,
     :conditions => nil,
     :limit => nil,
     :source_type => "Department",
     :source => :user_source,
     :group => nil,
     :through => :user_sinks_user_sources_as_user_sink,
     :order => nil,
     :extend => [Restriction::RestrictionDepartmentPolymorphicChildAssociationExtension],
     :class_name => "Department"
     # called from line 57

  has_many :roles,
     :conditions => nil,
     :limit => nil,
     :source_type => "Role",
     :source => :user_source,
     :group => nil,
     :through => :user_sinks_user_sources_as_user_sink,
     :order => nil,
     :extend => [Restriction::RestrictionRolePolymorphicChildAssociationExtension],
     :class_name => "Role"
     # called from line 57

  has_many :users,
     :conditions => nil,
     :limit => nil,
     :source_type => "User",
     :source => :user_source,
     :group => nil,
     :through => :user_sinks_user_sources_as_user_sink,
     :order => nil,
     :extend => [Restriction::RestrictionUserPolymorphicChildAssociationExtension],
     :class_name => "User"
     # called from line 57

end
