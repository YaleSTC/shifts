class StatsController < ApplicationController

  def index
      return unless user_is_admin_of(current_department)
      @start_date = params[:start_date] ? Date.parse(params[:start_date]) : 1.week.ago.to_date
      @end_date = params[:end_date] ? Date.parse(params[:end_date]) : 1.day.ago.to_date

      @stats = {}

      users = current_department.active_users.sort_by(&:last_name)

      users.each do |u|
        user_stats = {}
  	    
  	    shifts = u.shifts.on_days(@start_date, @end_date).active

  	    user_stats[:name] = u.name
        
        user_stats[:num_shifts] = shifts.size
  	    user_stats[:num_late] = shifts.select{|s| s.late?}.size
        user_stats[:num_missed] = shifts.select{|s| s.missed?}.size
  	    user_stats[:num_left_early] = shifts.select{|s| s.left_early?}.size 
        #user_stats[:scheduled_duration] = shifts.map{|s| s.duration(actual = false)}.sum
  	    #user_stats[:actual_duration] = shifts.map{|s| s.duration(actual = true)}.sum
                
        @stats[u.id] = user_stats
      end
  
  end

end
