class UserSourceLink < ActiveRecord::Base
  belongs_to :user_sink, :polymorphic => :true
  belongs_to :user_source, :polymorphic => :true
end
