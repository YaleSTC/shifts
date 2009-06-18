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
  include PayformHelper
  describe "when newly created" do
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

  describe "when the user is finished adding jobs" do
    before(:each) do
      @payform = Payform.create!(valid_payform_attributes)
    end

    it "should not be approved unless submitted" do
      @payform.should_not be_submitted
      lambda {
        @payform.approve
      }.should raise_error("Payform cannot be approved until it is submitted")
      #can modify the above error message to fit with actual error message - wy
      @payform.submit
      lambda { @payform.approve }.should_not raise_error
    end

    it "should not be printed unless approved" do
      @payform.submit
      @payform.should_not be_approved
      lambda {
        @payform.print
      }.should raise_error("Payform cannot be printed until it is approved")
      #can modify the above error message to fit with actual error message - wy
      @payform.approve
      lambda { @payform.approve }.should_not raise_error
    end
  end


end

