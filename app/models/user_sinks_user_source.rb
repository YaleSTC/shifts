# Commented out because we have no more need for doubly polymorphic joins 
=begin
class UserSinksUserSource < ActiveRecord::Base
  belongs_to :user_source, :polymorphic => true
  belongs_to :user_sink,   :polymorphic => true
  
  acts_as_double_polymorphic_join(:user_sources => [:departments, :roles, :users],
                                  :user_sinks   => [:notices, :restrictions])
end
=end
