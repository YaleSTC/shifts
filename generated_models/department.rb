
class Department

  has_many :loc_groups,
     :dependent => :destroy
     # called from line 57

  has_many :departments_users,
     :dependent => :destroy
     # called from line 57

  has_many :users,
     :through => :departments_users
     # called from line 57

  has_many :locations,
     :through => :loc_groups
     # called from line 57

  has_many :data_types,
     :dependent => :destroy
     # called from line 57

  has_many :data_objects,
     :through => :data_types
     # called from line 57

  belongs_to :admin_permission,
     :dependent => :destroy,
     :class_name => "Permission"
     # called from line 57

  has_many ,
     payform
     # called from line 57

  has_many ,
     payform_set
     # called from line 57

  has_many ,
     categorie
     # called from line 57

  has_and_belongs_to_many ,
     user
     # called from line 57

  has_and_belongs_to_many ,
     role
     # called from line 57

  has_one ,
     department_config
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
     :conditions => "location_source_type = 'Department'",
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
     :extend => [Department::DepartmentNoticePolymorphicChildAssociationExtension],
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
     :extend => [Department::DepartmentRestrictionPolymorphicChildAssociationExtension],
     :class_name => "Restriction"
     # called from line 57

  has_many_polymorphs :user_sinks,
     :foreign_key => "user_source_id",
     :foreign_type_key => "user_source_type",
     :singular_reverse_association_id => :user_source,
     :as => :user_source,
     :through => :user_sinks_user_sources,
     :is_double => true,
     :conflicts => [],
     :from => [:restrictions,
     :sub_requests,
     :notices]
     # called from line 57

  has_many :user_sinks_user_sources_as_user_source,
     :foreign_key => "user_source_id",
     :conditions => "user_source_type = 'Department'",
     :dependent => :destroy,
     :as => :user_source,
     :extend => [],
     :class_name => "UserSinksUserSource"
     # called from line 57

  has_many :sub_requests,
     :conditions => nil,
     :limit => nil,
     :source_type => "SubRequest",
     :source => :user_sink,
     :group => nil,
     :through => :user_sinks_user_sources_as_user_source,
     :order => nil,
     :extend => [Department::DepartmentSubRequestPolymorphicChildAssociationExtension],
     :class_name => "SubRequest"
     # called from line 57

  has_many :notices,
     :conditions => nil,
     :limit => nil,
     :source_type => "Notice",
     :source => :user_sink,
     :group => nil,
     :through => :user_sinks_user_sources_as_user_source,
     :order => nil,
     :extend => [Department::DepartmentNoticePolymorphicChildAssociationExtension],
     :class_name => "Notice"
     # called from line 57

  has_many :restrictions,
     :conditions => nil,
     :limit => nil,
     :source_type => "Restriction",
     :source => :user_sink,
     :group => nil,
     :through => :user_sinks_user_sources_as_user_source,
     :order => nil,
     :extend => [Department::DepartmentRestrictionPolymorphicChildAssociationExtension],
     :class_name => "Restriction"
     # called from line 57

end
