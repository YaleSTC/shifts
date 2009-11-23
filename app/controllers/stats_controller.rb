require 'fastercsv'
class StatsController < ApplicationController

  def index
    department = current_department
    @stats = Stat.all.select { |s| s.department_ids.nil? || s.department_ids.split(',').include?(department.id.to_s) }
    @stat = Stat.new

    @location_groups = department.loc_groups.select {|lg| current_user.is_admin_of? lg}
    @locations = @location_groups.collect {|g| g.locations.active }.flatten

  end

  def new
    redirect_to stats_path
  end

  def create
    @stat = Stat.new(params[:stat])
    if @stat.save
      flash[:notice] = "Successfully generated stats."
      redirect_to @stat
    else
      render :action => 'new'
    end
  end

  # GET /stats/1
  # GET /stats/1.csv -- export table data to csv
  def show
    @stat = Stat.find(params[:id])
  rescue Exception => e
    redirect_with_flash "Can't find stat with id #{params[:id]}", stats_path
  else
    respond_to do |wants|
      wants.html
      wants.csv do
        csv_string = FasterCSV.generate do |csv|
          cname = @stat.group_by
          #header row
          csv << [cname.camelcase, "# Shifts", "# Late", "# Missed", "Actual/Scheduled"]
          #data rows
          @stat.send("#{cname}_list").each do |u|
            shift_list = Stat.send("split_to_#{cname}s",@stat.shifts)[u.id]  || []
            csv << [ cname.camelcase.constantize.find(u.id).name,
                     shift_list.size,
                     Stat.filter_late(shift_list).size,
                     Stat.filter_missed(shift_list).size,
                     "=#{Stat.actual_vs_scheduled(shift_list)}"]

          end
        end
        # render file
        send_data csv_string,
            :type => 'text/csv; charset=iso-8859-1; header=present',
            :disposition => "attachment; filename=stats.csv"

      end
    end
  end

  # PUT /stats/1
  # PUT /stats/1.xml
  def update
    @stat = Stat.find(params[:id])

    respond_to do |format|
      if @stat.update_attributes(params[:stat])
        format.html do
          if params[:more]
            redirect_to location_more_stat_path(@stat)
          else
            redirect_to(@stat)
          end
        end
        format.xml  { head :ok }
      else
        flash.now[:notice] = "Can't change this stats. Please contact admin"
        format.html { render :action => "show" }
        format.xml  { render :xml => @stat.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy_all
    Stat.destroy_all
    respond_to do |wants|
       wants.html { redirect_to stats_path }
       wants.js {
        render :text => "Empty!!!"
     }
    end
  end

  def location_more
    @stat = Stat.find(params[:id])
  end

end
