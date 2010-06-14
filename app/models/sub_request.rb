class SubRequest < ActiveRecord::Base
  belongs_to :shift
  belongs_to :user
  has_many :users
  
  validates_presence_of :reason
  validates_presence_of :shift
  validate :start_and_end_are_within_shift
  validate :mandatory_start_and_end_are_within_subrequest
  validate :start_less_than_end
  validate :not_in_the_past
  validate :user_does_not_have_concurrent_sub_request
  #validate :user_sources_are_users
  #validate :user_sources_have_permission 
  #TODO: Non-polymorphic validations the replace the above two
  
  #before_destroy :destroy_user_sinks_user_sources
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
          new_shift.start = just_mandatory ? sub_request.mandatory_start : sub_request.start
          new_shift.end = just_mandatory ? sub_request.mandatory_end : sub_request.end
          UserSinksUserSource.delete_all("#{:user_sink_type.to_sql_column} = #{"SubRequest".to_sql} AND #{:user_sink_id.to_sql_column} = #{sub_request.id.to_sql}")
          sub_request.destroy
          Shift.delete_part_of_shift(old_shift, new_shift.start, new_shift.end)
          new_shift.save!
          AppMailer.deliver_sub_taken_notification(sub_request, new_shift, new_shift.department)
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

  def user_is_eligible?(user)
    return false if self.user == user
    user.can_signup?(self.shift.loc_group)
  end

  def potential_takers
    !users_with_permission.empty? ? users_with_permission : roles_with_permission.collect(&:users).flatten.uniq
  end
  
  #returns users stated in user_sources and checks to make sure they still have permission
  def users_with_permission
      user_sources.uniq.select { |u| u.can_signup?(self.shift.loc_group) } 
  end

  #returns roles that currently have permission
  def roles_with_permission
     shift.location.loc_group.roles
  end  
    
  def sub_name
    sub_class = self.user_source_type.classify
    sub_name = sub_class.find(self.user_source_id).name.to_s
  end

  def has_started?
    self.start < Time.now
  end

  def add_errors(e)
    e = e.gsub("Validation failed: ", "")
    e.split(", ").each do |error|
      errors.add_to_base(error.gsub(",,", ", "))
    end
  end


  private

  def start_and_end_are_within_shift
    unless self.start.between?(self.shift.start, self.shift.end) && self.end.between?(self.shift.start, self.shift.end)
      errors.add_to_base("Sub Request must be within shift.")
    end
  end

  def mandatory_start_and_end_are_within_subrequest
    unless self.mandatory_start.between?(self.start, self.end) && self.mandatory_end.between?(self.start, self.end)
      errors.add_to_base("The mandatory portion of this sub request must be within the optional portion")
    end
  end

  def start_less_than_end
    if self.end <= self.start || self.mandatory_end <= self.mandatory_start
      errors.add_to_base("All start times must be before end times")
    end
  end

  def not_in_the_past
    errors.add_to_base("Can't create a sub request for a time that has already passed!") if self.start < Time.now
  end

  def user_does_not_have_concurrent_sub_request
    c = SubRequest.count(:all, :conditions => ["#{:shift_id.to_sql_column} = #{self.shift_id.to_sql} AND #{:start.to_sql_column} < #{self.end.to_sql} AND #{:end.to_sql_column} > #{self.start.to_sql}"])
    unless c.zero?
      errors.add_to_base("#{self.shift.user.name} has an overlapping sub request in that period") unless (self.id and c==1)
    end
  end

  #def destroy_user_sinks_user_sources
  #  UserSinksUserSource.delete_all("#{:user_sink_type.to_sql_column} = #{"SubRequest".to_sql} AND #{:user_sink_id.to_sql_column} = #{self.id.to_sql}")
  #end
  
  #  def user_sources_are_users
  #     c = self.user_sources.select { |s| s.class.to_s != "User"}
  #    unless c.blank? 
  #      msg = c.collect(&:class).uniq
  #      errors.add_to_base("Cannot add by source type#{msg.length>1 ? 's' : ''}: #{msg.join(",,")}")
  #    end
  #  end
  #  
  #  def user_sources_have_permission 
  #     c = self.user_sources.select { |user| user.class.to_s == "User" && !user.can_signup?(self.loc_group) }
  #    unless c.blank? 
  #      errors.add_to_base("The following users do not have permission to work in this location: #{c.map(&:name)* ",,"}") 
  #    end
  #  end
  
end

