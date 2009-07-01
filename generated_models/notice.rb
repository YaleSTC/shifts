
class Notice

  belongs_to :author,
     :class_name => "User"
     # called from line 57

  belongs_to :remover,
     :class_name => "User"
     # called from line 57

  belongs_to ,
     departmen
     # called from line 57

  has_many_polymorphs :location_sources,
     :conflicts => [],
     :foreign_type_key => "location_sink_type",
     :singular_reverse_association_id => :location_sink,
     :as => :location_sink,
     :foreign_key => "location_sink_id",
     :through => :location_sinks_location_sources,
     :is_double => true,
     :from => [:departments,
     :loc_groups,
     :locations]
     # called from line 57

  has_many :location_sinks_location_sources_as_location_sink,
     :conditions => "location_sink_type = 'Notice'",
     :dependent => :destroy,
     :as => :location_sink,
     :extend => [],
     :class_name => "LocationSinksLocationSource",
     :foreign_key => "location_sink_id"
     # called from line 57

  has_many :departments,
     :conditions => nil,
     :limit => nil,
     :source => :location_source,
     :group => nil,
     :source_type => "Department",
     :extend => [Notice::NoticeDepartmentPolymorphicChildAssociationExtension],
     :class_name => "Department",
     :through => :location_sinks_location_sources_as_location_sink,
     :order => nil
     # called from line 57

  has_many :loc_groups,
     :conditions => nil,
     :limit => nil,
     :source => :location_source,
     :group => nil,
     :source_type => "LocGroup",
     :extend => [Notice::NoticeLocGroupPolymorphicChildAssociationExtension],
     :class_name => "LocGroup",
     :through => :location_sinks_location_sources_as_location_sink,
     :order => nil
     # called from line 57

  has_many :locations,
     :conditions => nil,
     :limit => nil,
     :source => :location_source,
     :group => nil,
     :source_type => "Location",
     :extend => [Notice::NoticeLocationPolymorphicChildAssociationExtension],
     :class_name => "Location",
     :through => :location_sinks_location_sources_as_location_sink,
     :order => nil
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
     :conditions => "user_sink_type = 'Notice'",
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
     :extend => [Notice::NoticeUserPolymorphicChildAssociationExtension],
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
     :extend => [Notice::NoticeDepartmentPolymorphicChildAssociationExtension],
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
     :extend => [Notice::NoticeRolePolymorphicChildAssociationExtension],
     :class_name => "Role",
     :through => :user_sinks_user_sources_as_user_sink,
     :order => nil
     # called from line 57

  belongs_to :author,
     :class_name => "User"
     # called from line 57

  belongs_to :remover,
     :class_name => "User"
     # called from line 57

  belongs_to ,
     departmen
     # called from line 57

  has_many_polymorphs :location_sources,
     :conflicts => [],
     :foreign_type_key => "location_sink_type",
     :singular_reverse_association_id => :location_sink,
     :as => :location_sink,
     :foreign_key => "location_sink_id",
     :through => :location_sinks_location_sources,
     :is_double => true,
     :from => [:departments,
     :loc_groups,
     :locations]
     # called from line 57

  has_many :location_sinks_location_sources_as_location_sink,
     :conditions => "location_sink_type = 'Notice'",
     :dependent => :destroy,
     :as => :location_sink,
     :extend => [],
     :class_name => "LocationSinksLocationSource",
     :foreign_key => "location_sink_id"
     # called from line 57

  has_many :departments,
     :conditions => nil,
     :limit => nil,
     :source => :location_source,
     :group => nil,
     :source_type => "Department",
     :extend => [Notice::NoticeDepartmentPolymorphicChildAssociationExtension],
     :class_name => "Department",
     :through => :location_sinks_location_sources_as_location_sink,
     :order => nil
     # called from line 57

  has_many :loc_groups,
     :conditions => nil,
     :limit => nil,
     :source => :location_source,
     :group => nil,
     :source_type => "LocGroup",
     :extend => [Notice::NoticeLocGroupPolymorphicChildAssociationExtension],
     :class_name => "LocGroup",
     :through => :location_sinks_location_sources_as_location_sink,
     :order => nil
     # called from line 57

  has_many :locations,
     :conditions => nil,
     :limit => nil,
     :source => :location_source,
     :group => nil,
     :source_type => "Location",
     :extend => [Notice::NoticeLocationPolymorphicChildAssociationExtension],
     :class_name => "Location",
     :through => :location_sinks_location_sources_as_location_sink,
     :order => nil
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
     :conditions => "user_sink_type = 'Notice'",
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
     :extend => [Notice::NoticeUserPolymorphicChildAssociationExtension],
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
     :extend => [Notice::NoticeDepartmentPolymorphicChildAssociationExtension],
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
     :extend => [Notice::NoticeRolePolymorphicChildAssociationExtension],
     :class_name => "Role",
     :through => :user_sinks_user_sources_as_user_sink,
     :order => nil
     # called from line 57

end
