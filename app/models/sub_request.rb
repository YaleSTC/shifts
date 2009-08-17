class SubRequest < ActiveRecord::Base
  belongs_to :shift
  belongs_to :user

  validates_presence_of :reason
  validates_presence_of :shift
  validate :start_and_end_are_within_shift
  validate :mandatory_start_and_end_are_within_subrequest
  validate :start_less_than_end
  validate :not_in_the_past
  validate :user_does_not_have_concurrent_sub_request
  validate :has_user_sources
  #
  # Class methods
  #

  def self.take(sub_request, user, just_mandatory)

    if sub_request.user_is_eligible?(user)
        SubRequest.transaction do
          if just_mandatory
            sub_request.start = sub_request.mandatory_start
            sub_request.end = sub_request.mandatory_end
          end
          new_shift = sub_request.shift.clone
          old_shift = sub_request.shift
          new_shift.location = old_shift.location
          new_shift.user = user
          new_shift.start = sub_request.start
          new_shift.end = sub_request.end
          UserSinksUserSource.delete_all("#{:user_sink_type.to_sql_column} = #{"SubRequest".to_sql} AND #{:user_sink_id.to_sql_column} = #{sub_request.id.to_sql}")
          sub_request.destroy
          Shift.delete_part_of_shift(old_shift, new_shift.start, new_shift.end)
          new_shift.save!
          AppMailer.deliver_sub_taken_notification(sub_request, new_shift)
          return true
        end
  
    else
      return false
    end
  end

  #
  # Object methods
  #

  def user_is_eligible?(user)
    self.substitutes.include?(user) && self.user != user
  end

  def substitutes
    temp = self.user_sources
    temp.empty? ? [self.shift.department] : temp.collect{|s| s.users}.flatten.uniq
  end

  def sub_name
    sub_class = self.user_source_type.classify
    sub_name = sub_class.find(self.user_source_id).name.to_s
  end
  
  def who_can_take
    self.user_sinks_user_sources.each do |substitute|
      if substitute.user_source_type == "Department"
        "Users in the department:" #+ substitute.name.to_s
      elsif substitute.user_source_type == "Role"
        "Users who have the role: " #+ substitute.name.to_s
      else
        return "this user" #+ substitute.name.to_s
      end
    end
  end
  
  def has_started?
    self.start < Time.now
  end

  def add_errors(e)
    e = e.gsub("Validation failed: ", "")
    e.split(", ").each do |error| 
      errors.add_to_base(error)
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
  
  def has_user_sources 
    if self.user_sources.empty?
      errors.add_to_base("Someone must be able to take this sub request. Add a person department and/or role to 'People/groups eligible for this sub'")
    end
  end

end
