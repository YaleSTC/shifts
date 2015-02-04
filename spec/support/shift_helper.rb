module ShiftHelper
  # Capybara page finder helpers, does not modify browser state
  def shift_schedule_row(location_id, date)
    page.first("#location#{location_id}_#{date.strftime("%Y-%m-%d")}_events")
  end
end
