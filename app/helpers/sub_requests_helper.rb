module SubRequestsHelper

#calculates default_start/end and range_start/end_time
  def calculate_default_times

      @default_start = @sub_request.shift.start
      @default_end = @sub_request.shift.end
      @default_mandatory_start = @default_start
      @default_mandatory_end = @default_end


      @range_start_time = @sub_request.shift.start
      @range_end_time = @sub_request.shift.end

  end


end

