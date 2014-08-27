# == Schema Information
#
# Table name: reports
#
#  id         :integer          not null, primary key
#  shift_id   :integer
#  arrived    :datetime
#  departed   :datetime
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require File.dirname(__FILE__) + '/../spec_helper'

describe Report do

  it "should have many report items"
  end
  
  it "should belong to a shift"
  end

end
