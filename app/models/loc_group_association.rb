class LocGroupAssociation < ActiveRecord::Base
  belongs_to :postable, :polymorphic => true
  belongs_to :loc_group
end
