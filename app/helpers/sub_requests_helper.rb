module SubRequestsHelper

  def calculate_default_times_sub_requests
    @default_start_date = @sub_request.shift.start.to_date
    @default_end_date = @sub_request.shift.end.to_date
    @default_end_date -= 1.day if (@sub_request.shift.end.day == (@sub_request.shift.start.day + 1))

  end
end

