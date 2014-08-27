# == Schema Information
#
# Table name: calendars
#
#  id            :integer          not null, primary key
#  name          :string(255)
#  start_date    :datetime
#  end_date      :datetime
#  active        :boolean
#  department_id :integer
#  default       :boolean          default(FALSE)
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  public        :boolean
#

require File.dirname(__FILE__) + '/../spec_helper'

describe Calendar do
  it "should be valid" do
    Calendar.new.should be_valid
  end
end
