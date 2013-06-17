class LocGroupsNotice < ActiveRecord::Base
  self.primary_key = "loc_groups_notices_id"
  belongs_to :loc_group
  belongs_to :notice
end
