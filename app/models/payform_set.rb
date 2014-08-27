# == Schema Information
#
# Table name: payform_sets
#
#  id            :integer          not null, primary key
#  department_id :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

class PayformSet < ActiveRecord::Base

  has_many :payforms
  belongs_to :department



end
