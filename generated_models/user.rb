
class User

  has_and_belongs_to_many ,
     role
     # called from line 57

  has_many ,
     departments_user
     # called from line 57

  has_many :departments,
     :through => :departments_users
     # called from line 57

  has_many ,
     payform
     # called from line 57

  has_many :payform_items,
     :through => :payforms
     # called from line 57

  has_many ,
     shift
     # called from line 57

  has_many :notices,
     :as => :author
     # called from line 57

  has_many :notices,
     :as => :remover
     # called from line 57

  has_one ,
     punch_cloc
     # called from line 57

  has_one :user_config,
     :dependent => :destroy
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
     :conditions => "user_source_type = 'User'",
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
     :extend => [User::UserRestrictionPolymorphicChildAssociationExtension],
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
     :extend => [User::UserSubRequestPolymorphicChildAssociationExtension],
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
     :extend => [User::UserNoticePolymorphicChildAssociationExtension],
     :class_name => "Notice",
     :through => :user_sinks_user_sources_as_user_source,
     :order => nil
     # called from line 57

end
