module ShiftPreferencesHelper
  
  def location_preference_check(location, kind)
    loc_shift_preference = LocationsShiftPreference.find(:first, :conditions => {:shift_preference_id => @shift_preference.id, :location_id => location.id})
    if loc_shift_preference
      if loc_shift_preference.kind == kind
        return true
      else
        return false
      end
    else
      return false
    end
  end
  
end