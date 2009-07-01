
class SubRequest

  belongs_to ,
     shif
     # called from line 57

  has_many_polymorphs :user_sources,
     :conflicts => [],
     :foreign_type_key => "user_sink_type",
     :singular_reverse_association_id => :user_sink,
     :as => :user_sink,
     :foreign_key => "user_sink_id",
     :through => :user_sinks_user_sources,
     :is_double => true,
     :from => [:departments,
     :roles,
     :users]
     # called from line 57

  has_many :user_sinks_user_sources_as_user_sink,
     :conditions => "user_sink_type = 'SubRequest'",
     :dependent => :destroy,
     :as => :user_sink,
     :extend => [],
     :class_name => "UserSinksUserSource",
     :foreign_key => "user_sink_id"
     # called from line 57

  has_many :users,
     :conditions => nil,
     :limit => nil,
     :source => :user_source,
     :group => nil,
     :source_type => "User",
     :extend => [SubRequest::SubRequestUserPolymorphicChildAssociationExtension],
     :class_name => "User",
     :through => :user_sinks_user_sources_as_user_sink,
     :order => nil
     # called from line 57

  has_many :departments,
     :conditions => nil,
     :limit => nil,
     :source => :user_source,
     :group => nil,
     :source_type => "Department",
     :extend => [SubRequest::SubRequestDepartmentPolymorphicChildAssociationExtension],
     :class_name => "Department",
     :through => :user_sinks_user_sources_as_user_sink,
     :order => nil
     # called from line 57

  has_many :roles,
     :conditions => nil,
     :limit => nil,
     :source => :user_source,
     :group => nil,
     :source_type => "Role",
     :extend => [SubRequest::SubRequestRolePolymorphicChildAssociationExtension],
     :class_name => "Role",
     :through => :user_sinks_user_sources_as_user_sink,
     :order => nil
     # called from line 57

  belongs_to ,
     shif
     # called from line 57

  has_many_polymorphs :user_sources,
     :conflicts => [],
     :foreign_type_key => "user_sink_type",
     :singular_reverse_association_id => :user_sink,
     :as => :user_sink,
     :foreign_key => "user_sink_id",
     :through => :user_sinks_user_sources,
     :is_double => true,
     :from => [:departments,
     :roles,
     :users]
     # called from line 57

  has_many :user_sinks_user_sources_as_user_sink,
     :conditions => "user_sink_type = 'SubRequest'",
     :dependent => :destroy,
     :as => :user_sink,
     :extend => [],
     :class_name => "UserSinksUserSource",
     :foreign_key => "user_sink_id"
     # called from line 57

  has_many :users,
     :conditions => nil,
     :limit => nil,
     :source => :user_source,
     :group => nil,
     :source_type => "User",
     :extend => [SubRequest::SubRequestUserPolymorphicChildAssociationExtension],
     :class_name => "User",
     :through => :user_sinks_user_sources_as_user_sink,
     :order => nil
     # called from line 57

  has_many :departments,
     :conditions => nil,
     :limit => nil,
     :source => :user_source,
     :group => nil,
     :source_type => "Department",
     :extend => [SubRequest::SubRequestDepartmentPolymorphicChildAssociationExtension],
     :class_name => "Department",
     :through => :user_sinks_user_sources_as_user_sink,
     :order => nil
     # called from line 57

  has_many :roles,
     :conditions => nil,
     :limit => nil,
     :source => :user_source,
     :group => nil,
     :source_type => "Role",
     :extend => [SubRequest::SubRequestRolePolymorphicChildAssociationExtension],
     :class_name => "Role",
     :through => :user_sinks_user_sources_as_user_sink,
     :order => nil
     # called from line 57

end
