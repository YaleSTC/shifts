require 'test_helper'

class LocationTest < ActiveSupport::TestCase
  fixtures :locations
  fixtures :shifts
  
  def setup
    #There is something wrong with the setup. Get "comparison of ActiveSupport::TimeWithZone with nil" error
    @loc   = locations(:locations_001)
    @shift = shifts(:shifts_872)
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
    @shift.save
    @loc.deactivate
    assert !@shift.active
    @loc.active = true
    @shift.active = false
    @shift.save
    @loc.deactivate
    assert !@loc.active
  end
  
  test "activate method on shift (location active)" do
    @loc.active = true
    @shift.active = true
    @shift.save
    @loc.activate
    assert @shift.active
    @loc.active = true
    @shift.active = false
    @shift.save
    @loc.activate
    assert @loc.active
  end
  
  test "deactivate method on shift (location inactive)" do
    @loc.active = false
    @shift.active = true
    @shift.save
    @loc.deactivate
    assert !@shift.active
    @loc.active = false
    @shift.active = false
    @shift.save
    @loc.deactivate
    assert !@loc.active
  end
  
  test "activate method on shift (location inactive)" do
    @loc.active = false
    @shift.active = true
    @shift.save
    @loc.activate
    assert @shift.active
    @loc.active = false
    @shift.active = false
    @shift.save
    @loc.activate
    assert @loc.active
  end

end