class PublicViewController < ApplicationController

  skip_before_filter :login_check
  skip_before_filter CASClient::Frameworks::Rails::Filter
  helper :shifts
  
  def index
    #@date = params[:date].to_date
		@loc_group = LocGroup.first #change later
		@locations = @loc_group.locations.active
    @view_days = (Date.today..Date.today+7)
		
		
		#TODO:simplify this stuff:
    @dept_start_hour = current_department.department_config.schedule_start / 60
    @dept_end_hour = current_department.department_config.schedule_end / 60
    @hours_per_day = (@dept_end_hour - @dept_start_hour)
    @time_increment = current_department.department_config.time_increment
    @blocks_per_hour = 60/@time_increment.to_f
    @blocks_per_day = @blocks_per_hour * @hours_per_day
  end

end

