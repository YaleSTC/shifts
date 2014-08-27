# == Schema Information
#
# Table name: locations
#
#  id           :integer          not null, primary key
#  name         :string(255)
#  short_name   :string(255)
#  useful_links :text
#  max_staff    :integer
#  min_staff    :integer
#  priority     :integer
#  report_email :string(255)
#  active       :boolean
#  loc_group_id :integer
#  template_id  :integer
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  description  :string(255)
#  category_id  :integer
#

require 'test_helper'

class LocationTest < ActiveSupport::TestCase
  fixtures :locations
  fixtures :shifts
  
  def setup
    #There is something wrong with the setup. Get "comparison of ActiveSupport::TimeWithZone with nil" error
    @loc   = locations(:locations_001)
    @shift = shifts(:shifts_872)
    @shift.start = Time.now + 100
    @shift.end   = Time.now + 200
    @shift.save(false)
  end
  
  test "deactivate method on location" do
    @loc.active = true
    @loc.save
    @loc.deactivate
    assert !@loc.active
    @loc.active = false
    @loc.save
    @loc.deactivate
    assert !@loc.active
  end
  
  test "activate method on location" do
    @loc.active = true
    @loc.save
    @loc.activate
    assert @loc.active
    @loc.active = false
    @loc.save
    @loc.activate
    assert @loc.active
  end
  
  test "deactivate method on shift (location active)" do
    @loc.active = true
    @shift.active = true
    @shift.save(false)
    @loc.deactivate
    assert !@shift.active
    @loc.active = true
    @shift.active = false
    @shift.save(false)
    @loc.deactivate
    assert !@loc.active
  end
  
  test "activate method on shift (location active)" do
    @loc.active = true
    @shift.active = false
    @shift.save(false)
    @loc.activate
    assert @loc.active
    @loc.active = true
    @shift.active = false
    @shift.save(false)
    @loc.activate
    assert @loc.active
  end
  
  test "deactivate method on shift (location inactive)" do
    @loc.active = false
    @shift.active = true
    @shift.save(false)
    @loc.deactivate
    assert !@shift.active
    @loc.active = false
    @shift.active = false
    @shift.save(false)
    @loc.deactivate
    assert !@loc.active
  end
  
  test "activate method on shift (location inactive)" do
    @loc.active = false
    @shift.active = true
    @shift.save(false)
    @loc.activate
    assert @loc.active
    @loc.active = false
    @shift.active = false
    @shift.save(false)
    @loc.activate
    assert @loc.active
  end
  
  

end
