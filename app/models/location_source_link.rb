class LocationSourceLink < ActiveRecord::Base
  belongs_to :location_sink, :polymorphic => :true
  belongs_to :location_source, :polymorphic => :true
end
