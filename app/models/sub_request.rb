class SubRequest < ActiveRecord::Base
  belongs_to :shift
  delegate :user, :to => :shift
  has_and_belongs_to_many :requested_users, :class_name => 'User'
  validates_presence_of :reason, :shift
  validate :start_and_end_are_within_shift,
           :mandatory_start_and_end_are_within_subrequest,
           :start_less_than_end,
           :not_in_the_past,
           :user_does_not_have_concurrent_sub_request,
           :requested_users_have_permission
  attr_accessor :mandatory_start_date
  attr_accessor :mandatory_start_time
  attr_accessor :mandatory_end_date
  attr_accessor :mandatory_end_time
  attr_accessor :start_date
  attr_accessor :start_time
  attr_accessor :end_date
  attr_accessor :end_time

  #
  # Class methods
  #

  def self.take(sub_request, user, just_mandatory)
    if sub_request.user_is_eligible?(user)
        SubRequest.transaction do
          old_shift = sub_request.shift

          new_shift = sub_request.shift.clone
          new_shift.location = old_shift.location #association not handled by clone method
          new_shift.power_signed_up = true #so that you don't get blocked taking a sub due to validations
          new_shift.signed_in = false #if you take a sub for a shift, but the requestor has signed in this prevents an error
          new_shift.user = user
          if new_shift.start < Time.now && old_shift.department.department_config.can_take_passed_sub #if the sub request shift has already started, someone else can still sign up for the sub, but the start time will be the time you took the sub, to avoid the "not_in_the_past" validations
            new_shift.start = Time.now #
            new_shift.save_with_validation(false)
          else
            new_shift.start = just_mandatory ? sub_request.mandatory_start : sub_request.start
          end
          new_shift.end = just_mandatory ? sub_request.mandatory_end : sub_request.end
          sub_request.destroy
          email_start = new_shift.start.time
          email_end = new_shift.end.time
          Shift.delete_part_of_shift(old_shift, new_shift.start, new_shift.end)
          new_shift.save!
          ArMailer.deliver(ArMailer.create_sub_taken_notification(sub_request, new_shift, new_shift.department))
          sub_watch_users = sub_request.potential_takers.select {|u| u.user_config.taken_sub_email}
          for user in sub_watch_users
            ArMailer.deliver(ArMailer.create_sub_taken_watch(user, sub_request, new_shift, email_start, email_end, new_shift.department))
          end
          return true
        end
    else
      return false
    end
  end


  #
  # Object methods
  #

  # this could be a delegate method but that would require delating in location too. this is good for now
  def loc_group
    shift.location.loc_group
  end

  def location
    shift.location
  end

  def user_is_eligible?(user)
    #can uncomment line below to prevent a user from taking their own shift. 
    #return false if self.user == user
    user.can_signup?(self.shift.loc_group)
  end

  def potential_takers
    !users_with_permission.empty? ? users_with_permission : roles_with_permission.collect(&:users).flatten.uniq.select{ |u| u.is_active?(self.shift.department)}
  end

  def users_with_permission
    requested_users.uniq.select { |u| u.can_signup?(self.shift.loc_group) && u.is_active?(self.shift.department) }
  end

  #returns roles that currently have permission
  def roles_with_permission
     shift.location.loc_group.roles
  end

  def has_started?
    self.start < Time.now
  end

  def add_errors(e)
    e = e.gsub("Validation failed: ", "")
    e.split(", ").each do |error|                   #errors.add_to_base is tokenized by comma-space pattern
      errors.add_to_base(error.gsub(",,", ", "))    #problem: in comma-seperated lists, each item is incorrectly rendered as a seperate error
    end                                             #work-around: lists are printed as "item,,item,,item" which now swap to "item, item, item"
  end

  def join_date_and_time
    self.start ||= self.start_date.to_date.to_time + self.start_time.seconds_since_midnight
    self.end ||= self.end_date.to_date.to_time + self.end_time.seconds_since_midnight
    self.mandatory_start ||= self.mandatory_start_date.to_date.to_time + self.mandatory_start_time.seconds_since_midnight
    self.mandatory_end ||= self.mandatory_end_date.to_date.to_time + self.mandatory_end_time.seconds_since_midnight
  end


  private


  def start_and_end_are_within_shift
    unless self.start.between?(self.shift.start, self.shift.end) && self.end.between?(self.shift.start, self.shift.end)
      errors.add_to_base("Sub Request must be within shift.")
    end
  end

  def mandatory_start_and_end_are_within_subrequest
    unless self.mandatory_start.between?(self.start, self.end) && self.mandatory_end.between?(self.start, self.end)
      errors.add_to_base("The mandatory portion of this sub request must be within the optional portion.")

    end
  end

  def start_less_than_end
    if self.end <= self.start || self.mandatory_end <= self.mandatory_start
      errors.add_to_base("All start times must be before end times.")
    end
  end

  def not_in_the_past
    errors.add_to_base("Can't create a sub request for a time that has already passed.") if self.start < Time.now
  end

  def user_does_not_have_concurrent_sub_request
    c = SubRequest.count(:all, :conditions => ["#{:shift_id.to_sql_column} = #{self.shift_id.to_sql} AND #{:start.to_sql_column} < #{self.end.to_sql} AND #{:end.to_sql_column} > #{self.start.to_sql}"])
    unless c.zero?
      errors.add_to_base("#{self.shift.user.name} has an overlapping sub request in that period.") unless (self.id and c==1)
    end
  end

  def requested_users_have_permission
    c = self.requested_users.select { |user| !user.can_signup?(self.loc_group) || user==self.user}
      unless c.blank?
        errors.add_to_base("The following users do not have permission to work in this location: #{c.map(&:name)* ", "}")
    end
  end

end

