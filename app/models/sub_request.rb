class SubRequest < ActiveRecord::Base
  belongs_to :shift
  has_many :substitute_links, :class_name => "UserSourceLink", :as => :user_sink
  #has_many :user_sources, :through => :substitute_sources

  validates_presence_of :reason
  validates_presence_of :shift
  validate :start_and_end_are_within_shift
  validate :mandatory_start_and_end_are_within_subrequest
  validate :start_less_than_end
  validate :not_in_the_past
  validate :user_does_not_have_concurrent_sub_request
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

  def add_substitute_source(source)
      substitute_link = UserSourceLink.new
      substitute_link.user_source = source
      substitute_link.user_sink = self
      substitute_link.save!
  end

  def remove_all_substitute_sources
    UserSourceLink.delete_all(:user_sink_id => self.id)
  end

  def user_is_eligible?(user)
    self.substitutes.include?(user)
  end

  def user_sources
    self.substitute_links.empty? ? [self.shift.department] : self.substitute_links.collect{|s| s.user_source}
  end


  def substitutes
    self.user_sources.collect{|s| s.users}.flatten.uniq
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
    c = SubRequest.count(:all, :conditions => ['shift_id = ? AND start < ? AND end > ?', self.shift_id, self.end, self.start])
    unless c.zero?
      errors.add_to_base("#{self.shift.user.name} has an overlapping sub request in that period") unless (self.id and c==1)
    end
  end

end
