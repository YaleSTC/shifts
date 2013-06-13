class LocationAssociation < ActiveRecord::Base
  belongs_to :postable, :polymorphic => true
  belongs_to :location 
  
end
