module ShiftHelper
  # Capybara page finder helpers, does not modify browser state
  def shift_schedule_row(location_id)
    page.all("#location#{location_id}_#{@a_local_time.strftime("%Y-%m-%d")}_events")[0]
  end
end
