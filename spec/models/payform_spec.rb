require File.dirname(__FILE__) + '/../spec_helper'

module PayformHelper
  def valid_payform_attributes
    { :date => "2009-5-12".to_date,
      :monthly => false,
      :complex => false,
      :day => 1,
      :department_id => 1,
      :user_id => 1,
    }
  end
end

describe Payform do
  describe "when newly created" do
    include PayformHelper

    before(:each) do
      @payform = Payform.new
    end

    it "should be valid with valid attributes" do
      @payform.attributes = valid_payform_attributes
      @payform.should be_valid
    end

    [:date, :monthly, :complex, :day, :department_id, :user_id].each do |attribute|
      it "should be invalid without #{attribute}" do
        @payform.attributes = valid_payform_attributes.except(attribute)
        @payform.should_not be_valid
      end
    end

  end
end

