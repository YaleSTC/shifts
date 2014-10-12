# == Schema Information
#
# Table name: data_fields
#
#  id           :integer          not null, primary key
#  data_type_id :integer
#  name         :string(255)
#  display_type :string(255)
#  values       :string(255)
#  upper_bound  :float
#  lower_bound  :float
#  exact_alert  :string(255)
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  active       :boolean          default(TRUE)
#

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

module DataFieldHelper
  def valid_data_field_attributes
    { data_type_id: "1",
      name: "Color",
      display_type: "check_box",
      values: "green, yellow, blue, orange"
    }
  end
end

describe DataField do
  include DataFieldHelper

  describe "when newly created" do
    before(:each) do
      @data_field = DataField.new
    end

    it "should be valid with valid attributes" do
      @data_field.attributes = valid_data_field_attributes
      @data_field.should be_valid
    end

    [:data_type_id, :name, :display_type].each do |attribute|
      it "should not be valid without #{attribute}" do
        @data_field.attributes = valid_data_field_attributes.except(attribute)
        @data_field.should_not be_valid
      end
    end

    it "should have a unique name" do
      @data_field.attributes = valid_data_field_attributes
      @data_field.save!
      data_field2 = DataField.new
      data_field2.attributes = valid_data_field_attributes
      data_field2.should_not be_valid
    end

  end
end

