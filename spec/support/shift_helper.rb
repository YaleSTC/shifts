module ShiftHelper
  # Capybara expectation helpers, does not modify browser state
  def expect_shift_on_schedule(location_id, date, name)
    expect(page).to have_selector("ul#location#{location_id}_#{date.strftime("%Y-%m-%d")}_events>li", text: name)
  end


  # Capybara page finder helpers, does not modify browser state
  def shift_schedule_row(location_id, date)
    page.first("#location#{location_id}_#{date.strftime("%Y-%m-%d")}_events")
  end

  def shift_in_schedule(shift)
  	shift_schedule_row(shift.location.id, shift.start).first("li#shift#{shift.id}")
  end
end
