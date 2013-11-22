require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

module DataObjectHelper
  def valid_data_object_attributes
    { data_type_id: "1",
      location_id: "1",
      name: "cat",
      description: "makes me sneeze"
    }
  end
end



describe DataObject do
  include DataObjectHelper

  describe "when newly created" do
    before(:each) do
      @data_object = DataObject.new
    end

    it "should be valid with valid attributes" do
      @data_object.attributes = valid_data_object_attributes
      @data_object.should be_valid
    end

    [:data_type_id, :location_id, :name].each do |attribute|
      it "should not be valid without #{attribute}" do
        @data_object.attributes = valid_data_object_attributes.except(attribute)
        @data_object.should_not be_valid
      end
    end

    it "should have a unique name" do
      @data_object.attributes = valid_data_object_attributes
      @data_object.save!
      data_object2 = DataObject.new
      data_object2.attributes = valid_data_object_attributes
      data_object2.should_not be_valid
      data_object2.should raise_error(NameError)
    end

  end
end

