class LocGroupsNotice < ActiveRecord::Base
  belongs_to :loc_group
  belongs_to :notice
end
