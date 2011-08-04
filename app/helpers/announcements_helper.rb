module AnnouncementsHelper

  def calculate_default_times
#the following start code was written together with the end code, but it has not been tested yet. ~Casey
#    if @announcement.start
#      @default_start_date = @announcement.start.to_date
#    else
#      @default_start_date = Date.today
#    end
    @default_start_date = Date.today

    if @announcement.end
      @default_end_date = @announcement.end.to_date
    else
      @default_end_date = @default_start_date
    end

#    @announcement.start ||= @default_start_date.to_time + current_department.department_config.schedule_start.minutes
#    @announcement.end ||= @default_end_date.to_time  + current_department.department_config.schedule_end.minutes

  end

end
