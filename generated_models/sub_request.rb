
class SubRequest

  belongs_to ,
     shif
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
     :conditions => "user_sink_type = 'SubRequest'",
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
     :extend => [SubRequest::SubRequestDepartmentPolymorphicChildAssociationExtension],
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
     :extend => [SubRequest::SubRequestRolePolymorphicChildAssociationExtension],
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
     :extend => [SubRequest::SubRequestUserPolymorphicChildAssociationExtension],
     :class_name => "User"
     # called from line 57

end
