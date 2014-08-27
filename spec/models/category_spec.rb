# == Schema Information
#
# Table name: categories
#
#  id            :integer          not null, primary key
#  active        :boolean          default(TRUE)
#  built_in      :boolean          default(FALSE)
#  name          :string(255)
#  department_id :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  billing_code  :string(255)
#

require File.dirname(__FILE__) + '/../spec_helper'

describe Category do
  it "should be valid" do
    Category.new.should be_valid
  end
end
