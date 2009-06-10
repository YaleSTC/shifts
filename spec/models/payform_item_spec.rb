require File.dirname(__FILE__) + '/../spec_helper'

module PayformItemHelper
  def valid_payform_item_attributes
    { :category_id => 1,
      :user_id => 1,
      :hours => 3,
      :description => "Fun"
    }
  end
end

describe PayformItem do
  include PayformItemHelper
  describe "when newly created" do
    before(:each) do
      @payform_item = PayformItem.new
    end

    it "should be valid with valid attributes" do
      @payform_item.attributes = valid_payform_item_attributes
      @payform_item.should be_valid
    end

    [:category_id, :user_id, :hours, :description].each do |attribute|
      it "should be invalid without #{attribute}" do
        @payform_item.attributes = valid_payform_item_attributes.except(attribute)
        @payform_item.should_not be_valid
      end
    end
  end

  describe "when edited" do
    before(:each) do
      @payform_item = PayformItem.create(valid_payform_item_attributes)
      @payform_item.should be_active
      PayformItem.update(@payform_item.id, {:description => "I've been edited'"})
    end

    it "should not be active" do
      @payform_item.should_not be_active
    end

    it "should have a child with the new attribute" do
      children = @payform_item.children
      children.should_not be_empty
      children.first.description.should match("I've been edited")
    end

    it "should not have changed its own attributes" do
      @payform_item.description.should match("Fun")
    end
  end
end

