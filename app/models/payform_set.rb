class PayformSet < ActiveRecord::Base

  has_many :payforms
  belongs_to :department



end
