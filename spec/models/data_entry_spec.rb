# == Schema Information
#
# Table name: data_entries
#
#  id             :integer          not null, primary key
#  data_object_id :integer
#  content        :text
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

module DataTypeHelper
  def valid_data_type_attributes
    { name: "pet",
      description: "warm and cuddly",
      department_id: "1"
    }
  end
end

describe DataType do
  include DataTypeHelper
  describe "when newly created" do
    before(:each) do
      @data_type = DataType.new
    end

    it "should be valid with valid attributes" do
      @data_type.attributes = valid_data_type_attributes
      @data_type.should be_valid
    end

    [:name, :department_id].each do |attribute|
      it "should be invalid without #{attribute}" do
        @data_type.attributes = valid_data_type_attributes.except(attribute)
        @data_type.should_not be_valid
      end
    end

    it "should have a unique name" do
      @data_type.attributes = valid_data_type_attributes
      @data_type.save!
      data_type2 = DataType.create(valid_data_type_attributes)
      data_type2.should_not be_valid
    end

  end
end

