
class LocGroup

  belongs_to ,
     departmen
     # called from line 57

  belongs_to :view_permission,
     :foreign_key => "view_perm_id",
     :dependent => :destroy,
     :class_name => "Permission"
     # called from line 57

  belongs_to :signup_permission,
     :foreign_key => "signup_perm_id",
     :dependent => :destroy,
     :class_name => "Permission"
     # called from line 57

  belongs_to :admin_permission,
     :foreign_key => "admin_perm_id",
     :dependent => :destroy,
     :class_name => "Permission"
     # called from line 57

  has_many :locations,
     :dependent => :destroy
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
     :conditions => "location_source_type = 'LocGroup'",
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
     :extend => [LocGroup::LocGroupNoticePolymorphicChildAssociationExtension],
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
     :extend => [LocGroup::LocGroupRestrictionPolymorphicChildAssociationExtension],
     :class_name => "Restriction"
     # called from line 57

end
