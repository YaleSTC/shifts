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

describe PayformItemsController do
  include PayformItemHelper
  fixtures :all
  render_views

  describe ", when making a Parent Payform Item," do
    before(:each) do
      @payform_item = PayformItem.create!(valid_payform_item_attributes)
      @payform_item.edit(id: 1,
                         user_id: 1,
                         category_id: 1,
                         hours: 2,
                         date: "2009-5-23".to_date,
                         description: "Fun Times in New Haven",
                         reason: "I forgot how long it was")
    end

    it "the child should not be active if it has a parent"

  end
end

