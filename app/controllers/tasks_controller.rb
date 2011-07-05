class TasksController < ApplicationController
  # GET /tasks
  # GET /tasks.xml

  def index
    @tasks = Task.all
    @active_tasks = Task.find(:all, :conditions => ["#{:active} = ?", true])
    @inactive_tasks = Task.find(:all, :conditions => ["#{:active} = ?", false])
    

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @tasks }
    end
  end

  # GET /tasks/1
  # GET /tasks/1.xml
  def show
    @task = Task.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @task }
    end
  end

  # GET /tasks/new
  # GET /tasks/new.xml
  def new
    @task = Task.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @task }
    end
  end

  # GET /tasks/1/edit
  def edit
    @task = Task.find(params[:id])
  end

  # POST /tasks
  # POST /tasks.xml
  def create
    @task = Task.new(params[:task])

    respond_to do |format|
      if @task.save
        flash[:notice] = 'Task was successfully created.'
        format.html { redirect_to(@task) }
        format.xml  { render :xml => @task, :status => :created, :location => @task }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @task.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /tasks/1
  # PUT /tasks/1.xml
  def update
    # raise params.to_yaml
    @task = Task.find(params[:id])

    respond_to do |format|
      if @task.update_attributes(params[:task])
        flash[:notice] = 'Task was successfully updated.'
        format.html { redirect_to(@task) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @task.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /tasks/1
  # DELETE /tasks/1.xml
  def destroy
    @task = Task.find(params[:id])
    @task.destroy

    respond_to do |format|
      format.html { redirect_to(tasks_url) }
      format.xml  { head :ok }
    end
  end
  
  def make_entry
    # raise params.to_yaml
    @shift = current_user.current_shift
    @tasks = tasks_during_shift

    params[:task_ids].each do |task_id|
      @shifts_task = ShiftsTask.new(:task_id => task_id, :shift_id => @shift.id, :missed => false )
  		@shifts_task.save
		end
		  if @report = current_user.current_shift.report
        @report.report_items << ReportItem.new(:time => Time.now, :content => "#{Task.find(@shifts_task.task_id).name} completed.", :ip_address => request.remote_ip)
      end
    respond_to do |format|
      format.js
      format.html {redirect_to @report ? @report : @shift_task.data_object}
    end
  end
  
  def update_tasks
    @shift = current_user.current_shift
    @tasks = tasks_during_shift
    respond_to do |format|
      format.js
    end
  end


  def completed_tasks
    @start_date = interpret_start
    @end_date = interpret_end
    @task = Task.find(params[:id])
    @shifts = ShiftsTask.find(:all, :conditions => {:task_id => @task.id, :missed => false})
    @shifts_tasks = @shifts.select{|st| st.created_at > @end_date && st.created_at < @start_date}
  
  
  end
  
  def missed_tasks
    @task = Task.find(params[:id])
    # should be renamed but currently constrained because of a dependency in a view partial (task items)
    @shifts_tasks = ShiftsTask.find(:all, :conditions => {:task_id => @task.id, :missed => true})
  end
  
  protected
  
  def tasks_during_shift
    # active, non-expired tasks
    tasks = Task.in_location(current_user.current_shift.location).active.after_now
    # filters out daily and weekly tasks scheduled for a time later in the day
    tasks = tasks.delete_if{|t| t.kind != "Hourly" && Time.now.seconds_since_midnight <= t.time_of_day.seconds_since_midnight}
    # filters out weekly tasks on the wrong day
    tasks = tasks.delete_if{|t| t.kind == "Weekly" && t.day_in_week != @shift.start.strftime("%a") }
  end
    
   def interpret_start
    if params[:task]
      return Date.civil(params[:task][:"start_date(1i)"].to_i,params[:task][:"start_date(2i)"].to_i,params[:task][:"start_date(3i)"].to_i)
    elsif params[:start_date]
      return params[:start_date].to_date
    else
      return 1.week.ago.to_date
    end
  end

  def interpret_end
    if params[:task]
      return Date.civil(params[:task][:"end_date(1i)"].to_i,params[:task][:"end_date(2i)"].to_i,params[:task][:"end_date(3i)"].to_i)
    elsif params[:end_date]
      return params[:end_date].to_date
    else
      return Date.today.to_date
    end
  end

        
end