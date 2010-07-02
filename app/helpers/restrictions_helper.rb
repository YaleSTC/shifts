module RestrictionsHelper
#calculates default_start/end and range_start/end_time
  def calculate_default_times

      @restriction.starts ||= (params[:date] ? Time.parse(params[:date]) : Time.now).to_date.to_time + current_department.department_config.schedule_start.minutes
      @restriction.expires ||= @shift.starts + 1.hour

    @range_start_time = Time.now.to_date + current_department.department_config.schedule_start.minutes
    @range_end_time = Time.now.to_date + current_department.department_config.schedule_end.minutes
  end

end

