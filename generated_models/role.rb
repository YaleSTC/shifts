
class Role

  has_and_belongs_to_many ,
     department
     # called from line 57

  has_and_belongs_to_many ,
     permission
     # called from line 57

  has_and_belongs_to_many ,
     user
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
     :conditions => "user_source_type = 'Role'",
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
     :extend => [Role::RoleSubRequestPolymorphicChildAssociationExtension],
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
     :extend => [Role::RoleNoticePolymorphicChildAssociationExtension],
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
     :extend => [Role::RoleRestrictionPolymorphicChildAssociationExtension],
     :class_name => "Restriction"
     # called from line 57

end
