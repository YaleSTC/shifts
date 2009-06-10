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
  describe "when newly created" do
    include PayformItemHelper

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

  describe "already created" do
  end
end

