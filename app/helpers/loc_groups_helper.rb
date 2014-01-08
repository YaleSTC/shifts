module LocGroupsHelper
  def preprocess_loc_group(loc_group)
    #TODO:simplify this stuff:
  	@locations = loc_group.locations.active
    @dept_start_hour = loc_group.department.department_config.schedule_start / 60
    @dept_end_hour = loc_group.department.department_config.schedule_end / 60
    @hours_per_day = (@dept_end_hour - @dept_start_hour)
    @time_increment = loc_group.department.department_config.time_increment
    @blocks_per_hour = 60/@time_increment.to_f
    @blocks_per_day = @blocks_per_hour * @hours_per_day
    @day_blockset = []
    @dept_start_time = Time.now.change(hour: @dept_start_hour)
    for block in 1..@blocks_per_day
      @day_blockset << @dept_start_time + (block - 1)*@time_increment.minutes
    end
  end
end
