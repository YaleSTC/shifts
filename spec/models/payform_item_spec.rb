# == Schema Information
#
# Table name: payform_items
#
#  id                  :integer          not null, primary key
#  category_id         :integer
#  user_id             :integer
#  payform_id          :integer
#  payform_item_set_id :integer
#  active              :boolean          default(TRUE)
#  hours               :decimal(10, 2)
#  date                :date
#  description         :text
#  reason              :text
#  source              :string(255)
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  source_url          :string(255)
#

require File.dirname(__FILE__) + '/../spec_helper'

module PayformItemHelper
  def valid_payform_item_attributes
    { id: 1,
      user_id: 1,
      category_id: 1,
      hours: 3,
      date: "2009-5-23".to_date,
      description: "Fun Times in New Haven"
    }
  end
end


describe PayformItem do
  include PayformItemHelper
  describe ", when Newly Created," do

    before(:each) do
      @payform_item = PayformItem.new
    end

    [:user_id, :description, :category_id, :hours, :date].each do |attribute|
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

end

