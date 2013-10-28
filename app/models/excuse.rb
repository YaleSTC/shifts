class Excuse < ActiveRecord::Base
  belongs_to :shift

  validates :shift_id, presence: true
  # validates :excuse,  presence: true
end
