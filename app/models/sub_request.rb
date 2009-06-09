class SubRequest < ActiveRecord::Base
  belongs_to :shift
  validates_presence_of :reason
  validate :start_and_end_are_within_shift

  private
  def start_and_end_are_within_shift
    unless self.start.between?(self.shift.start, self.shift.end) && self.end.between?(self.shift.start, self.shift.end)
      errors.add("Sub Request must be within shift.", "")
    end
  end
end
