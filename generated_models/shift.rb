
class Shift

  belongs_to ,
     use
     # called from line 57

  belongs_to ,
     locatio
     # called from line 57

  has_one :report,
     :dependent => :destroy
     # called from line 57

  has_many :sub_requests,
     :dependent => :destroy
     # called from line 57

end
