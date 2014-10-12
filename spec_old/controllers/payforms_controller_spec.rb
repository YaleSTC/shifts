require File.dirname(__FILE__) + '/../spec_helper'

module PayformHelper
  def valid_payform_attributes
    { date: "2009-5-12".to_date,
      monthly: false,
      end_of_month: false,
      day: 1,
      department_id: 1,
      user_id: 1,
    }
  end
end

describe PayformsController do
  include PayformHelper
  fixtures :all
  render_views

    describe "after adding jobs" do
    before(:each) do
      @payform = Payform.create!(valid_payform_attributes)
    end

    it "should not be approved unless submitted" do
      @payform.should_not be_submitted
      lambda {
        @payform.approved
      }.should raise_error("Payform cannot be approved until it is submitted")
      #can modify the above error message to fit with actual error message - wy
      @payform.submit
      lambda { @payform.approve }.should_not raise_error
    end

    it "should not be printed unless approved" do
      @payform.submitted
      @payform.should_not be_approved
      lambda {
        @payform.printed
      }.should raise_error("Payform cannot be printed until it is approved")
      #can modify the above error message to fit with actual error message - wy
      @payform.approved
      lambda { @payform.approve }.should_not raise_error
    end
  end
end

