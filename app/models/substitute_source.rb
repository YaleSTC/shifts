class SubstituteSource < ActiveRecord::Base
  belongs_to :sub_request
  belongs_to :user_source, :polymorphic => :true
end

