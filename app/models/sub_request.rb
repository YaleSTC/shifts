class SubRequest < ActiveRecord::Base
  belongs_to :shift
  validates_presence_of :reason
end
