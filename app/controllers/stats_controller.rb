class StatsController < ApplicationController
  def index
      @start_date = params[:start_date] || 1.week.ago
      @start_date = params[:end_date] || Date.today
      @stats = {}

      all_users = current_department.active_users

      all_users.each do |u|
  	    
  	    @user_stats = {}
  	    shifts = u.shifts.on_days(@start_date, @end_date).active
  	    reports = shifts.map( &:report).compact

  	    @user_stats[:num_shifts] = shifts.size
  	    @user_stats[:num_reports] = reports.size
  	    @user_stats[:num_late] = reports.select{|r| r.late?}.size
  	    @user_stats[:num_left_early] = reports.select{|r| r.left_early?}.size 
        @user_stats[:num_missed] = num_shifts - num_reports
                                         
  	    @user_stats[:scheduled_duration] = shifts.map{|s| s.duration(actual = false)}.sum
  	    @user_stats[:real_duration] = shifts.map{|s| s.duration(actual = true)}.sum

  	    print "\t", num_shifts, "\t", num_reports, "\t", num_missed, "\t", num_late, "\t",  num_left_early, "\t", scheduled_duration,"\t", real_duration, "\n"
      end
    end

  def show
  end

end
