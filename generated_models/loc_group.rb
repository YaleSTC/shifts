
class LocGroup

  belongs_to ,
     departmen
     # called from line 57

  belongs_to :view_permission,
     :dependent => :destroy,
     :foreign_key => "view_perm_id",
     :class_name => "Permission"
     # called from line 57

  belongs_to :signup_permission,
     :dependent => :destroy,
     :foreign_key => "signup_perm_id",
     :class_name => "Permission"
     # called from line 57

  belongs_to :admin_permission,
     :dependent => :destroy,
     :foreign_key => "admin_perm_id",
     :class_name => "Permission"
     # called from line 57

  has_many :locations,
     :dependent => :destroy
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
     :conditions => "location_source_type = 'LocGroup'",
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
     :extend => [LocGroup::LocGroupRestrictionPolymorphicChildAssociationExtension],
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
     :extend => [LocGroup::LocGroupNoticePolymorphicChildAssociationExtension],
     :class_name => "Notice",
     :through => :location_sinks_location_sources_as_location_source,
     :order => nil
     # called from line 57

  
end
