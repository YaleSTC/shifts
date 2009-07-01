
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
     :conflicts => [],
     :foreign_type_key => "user_source_type",
     :singular_reverse_association_id => :user_source,
     :as => :user_source,
     :foreign_key => "user_source_id",
     :through => :user_sinks_user_sources,
     :is_double => true,
     :from => [:restrictions,
     :sub_requests,
     :notices]
     # called from line 57

  has_many :user_sinks_user_sources_as_user_source,
     :conditions => "user_source_type = 'Role'",
     :dependent => :destroy,
     :as => :user_source,
     :extend => [],
     :class_name => "UserSinksUserSource",
     :foreign_key => "user_source_id"
     # called from line 57

  has_many :restrictions,
     :conditions => nil,
     :limit => nil,
     :source => :user_sink,
     :group => nil,
     :source_type => "Restriction",
     :extend => [Role::RoleRestrictionPolymorphicChildAssociationExtension],
     :class_name => "Restriction",
     :through => :user_sinks_user_sources_as_user_source,
     :order => nil
     # called from line 57

  has_many :sub_requests,
     :conditions => nil,
     :limit => nil,
     :source => :user_sink,
     :group => nil,
     :source_type => "SubRequest",
     :extend => [Role::RoleSubRequestPolymorphicChildAssociationExtension],
     :class_name => "SubRequest",
     :through => :user_sinks_user_sources_as_user_source,
     :order => nil
     # called from line 57

  has_many :notices,
     :conditions => nil,
     :limit => nil,
     :source => :user_sink,
     :group => nil,
     :source_type => "Notice",
     :extend => [Role::RoleNoticePolymorphicChildAssociationExtension],
     :class_name => "Notice",
     :through => :user_sinks_user_sources_as_user_source,
     :order => nil
     # called from line 57

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
     :conflicts => [],
     :foreign_type_key => "user_source_type",
     :singular_reverse_association_id => :user_source,
     :as => :user_source,
     :foreign_key => "user_source_id",
     :through => :user_sinks_user_sources,
     :is_double => true,
     :from => [:restrictions,
     :sub_requests,
     :notices]
     # called from line 57

  has_many :user_sinks_user_sources_as_user_source,
     :conditions => "user_source_type = 'Role'",
     :dependent => :destroy,
     :as => :user_source,
     :extend => [],
     :class_name => "UserSinksUserSource",
     :foreign_key => "user_source_id"
     # called from line 57

  has_many :restrictions,
     :conditions => nil,
     :limit => nil,
     :source => :user_sink,
     :group => nil,
     :source_type => "Restriction",
     :extend => [Role::RoleRestrictionPolymorphicChildAssociationExtension],
     :class_name => "Restriction",
     :through => :user_sinks_user_sources_as_user_source,
     :order => nil
     # called from line 57

  has_many :sub_requests,
     :conditions => nil,
     :limit => nil,
     :source => :user_sink,
     :group => nil,
     :source_type => "SubRequest",
     :extend => [Role::RoleSubRequestPolymorphicChildAssociationExtension],
     :class_name => "SubRequest",
     :through => :user_sinks_user_sources_as_user_source,
     :order => nil
     # called from line 57

  has_many :notices,
     :conditions => nil,
     :limit => nil,
     :source => :user_sink,
     :group => nil,
     :source_type => "Notice",
     :extend => [Role::RoleNoticePolymorphicChildAssociationExtension],
     :class_name => "Notice",
     :through => :user_sinks_user_sources_as_user_source,
     :order => nil
     # called from line 57

end
