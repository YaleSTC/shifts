
class Payform

  has_many ,
     payform_item
     # called from line 57

  belongs_to ,
     payform_se
     # called from line 57

  belongs_to ,
     departmen
     # called from line 57

  belongs_to ,
     use
     # called from line 57

  belongs_to :approved_by,
     :foreign_key => "approved_by_id",
     :class_name => "User"
     # called from line 57

  has_many ,
     payform_item
     # called from line 57

  belongs_to ,
     payform_se
     # called from line 57

  belongs_to ,
     departmen
     # called from line 57

  belongs_to ,
     use
     # called from line 57

  belongs_to :approved_by,
     :foreign_key => "approved_by_id",
     :class_name => "User"
     # called from line 57

  has_many ,
     payform_item
     # called from line 57

  belongs_to ,
     payform_se
     # called from line 57

  belongs_to ,
     departmen
     # called from line 57

  belongs_to ,
     use
     # called from line 57

  belongs_to :approved_by,
     :foreign_key => "approved_by_id",
     :class_name => "User"
     # called from line 57

end
