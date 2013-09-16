class Department < ActiveRecord::Base
  belongs_to :admin_permission, :class_name => "Permission", :dependent => :destroy
  has_one :department_config, :dependent => :destroy
  has_many :loc_groups, :dependent => :destroy
  has_many :departments_users, :dependent => :destroy
  has_many :users, :through => :departments_users
  has_many :roles, :dependent => :destroy
  has_many :shifts
  has_many :locations, :through => :loc_groups
  has_many :data_types, :dependent => :destroy
  has_many :data_objects, :through => :data_types
  has_many :payforms
  has_many :payform_sets
  has_many :categories
  has_many :punch_clocks
  has_many :punch_clock_sets
  has_many :user_profile_fields
  has_many :calendars, :dependent => :destroy do
    def default
      find(:first, :conditions => {:default => true})
    end
  end

  before_validation(:on => :create) {:create_permissions}
  before_validation(:on => :update) {:update_permissions}
  validates_uniqueness_of :name
  validates_uniqueness_of :admin_permission_id

  def links
     ActiveRecord::Base.transaction do
        a = UserSinksUserSource.find(:all, :conditions => ["user_sink_type = 'Notice' AND user_source_type = 'Department' AND user_source_id = #{self.id.to_sql}"]).collect(&:user_sink_id)
        b = Link.active.collect(&:id)
        Link.find(a & b) 
      end
  end
  
# Returns all users active in a given department
  def active_users
    joins = DepartmentsUser.find(:all, :conditions => {:department_id => self, :active => true })
    joins.map{|j| User.find(j.user_id)}
  end

# Simplifies some permission-checking methods greatly
  def department
    self
  end
  
  def current_notices
    ActiveRecord::Base.transaction do
      a = UserSinksUserSource.find(:all, :conditions => ["user_sink_type = 'Notice' AND user_source_type = 'Department' AND user_source_id = #{self.id.to_sql}"]).collect(&:user_sink_id)
      y = Announcement.active.collect(&:id)
      Notice.find(a & y).sort_by{|n| n.start}
    end
  end
    
  def sub_requests
    SubRequest.find(:all, :conditions => ["end >= ?", Time.now]).select { |sub| sub.shift.department == self }
  end
  
#  has_and_belongs_to_many :users
  private
  def create_permissions
    self.create_admin_permission(:name => name + " dept admin")
  end

  # in case department name is changed, should update permissions accordingly
  def update_permissions
    self.admin_permission.update_attribute(:name, name + " dept admin")
  end

end

