# == Schema Information
#
# Table name: punch_clock_sets
#
#  id            :integer          not null, primary key
#  description   :string(255)
#  department_id :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

class PunchClockSet < ActiveRecord::Base
  has_many :punch_clocks, dependent: :destroy
  belongs_to :department

  validates_presence_of :description
  validate :length_of_description

  def users
    self.punch_clocks.map{|pc| pc.users}.flatten
  end

  def running_time
    no_of_sec = Time.now - self.created_at
    [ no_of_sec / 3600, no_of_sec / 60 % 60, no_of_sec % 60 ].map{ |t| t.to_i.to_s.rjust(2, '0') }.join(':')
  end

private

  def length_of_description
    min = self.department.department_config.description_min
    if self.description.length < min
      errors.add(:base, "Description must be at least #{min} characters long.") 
    end
  end   

end
