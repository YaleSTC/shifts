class Location < ActiveRecord::Base

  belongs_to :loc_group

  def department #oh poo. belongs_to :through is coming down the channel in edge rails, but not here yet...
    loc_group.department
  end

end

