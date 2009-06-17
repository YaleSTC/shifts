require File.dirname(__FILE__) + '/../spec_helper'

module PayformItemHelper
  def valid_payform_item_attributes
    { :payform_item_id => 1,
      :user_id => 1,
      :category_id => 1,
      :hours => 3,
      :description => "Fun"
    }
  end
end


describe PayformItem do
  include PayformItemHelper
  describe "Newly Created" do

    before(:each) do
      @payform_item = PayformItem.new
    end

    [:user_id, :description, :category, :hours].each do |attribute|
      it "should be invalid without #{attribute}" do
        @payform_item.attributes = valid_payform_item_attributes.except(attribute)
        @payform_item.should_not be_valid
      end
    end

    it "should be valid with all attributes" do
      @payform_item.attributes = valid_payform_item_attributes
      @payform_item.should be_valid
    end
  end

  describe "Parent Payform Items" do
    before(:each) do
      @payform_item = PayformItem.create!(valid_payform_item_attributes)
      @payform_item.edit(:description => "wrong")

    it "should not be active if it has a child" do

    end

  end
end

