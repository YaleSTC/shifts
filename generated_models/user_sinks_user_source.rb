
class UserSinksUserSource

  belongs_to :user_source,
     :polymorphic => true
     # called from line 57

  belongs_to :user_sink,
     :polymorphic => true
     # called from line 57

  acts_as_double_polymorphic_join ,
     :user_sinks => [:restrictions,
     :sub_requests,
     :notices],
     :user_sources => [:departments,
     :roles,
     :users]
     # called from line 57

end
