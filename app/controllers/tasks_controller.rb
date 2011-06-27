class TasksController < ApplicationController
  # GET /tasks
  # GET /tasks.xml

  def index
    @tasks = Task.all

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
    @tasks = Task.in_location(current_user.current_shift.location).after_now
    @shift = current_user.current_shift
    
    params[:task_ids].each do |task_id|
      @shifts_task = ShiftsTask.new(:task_id => task_id, :shift_id => @shift.id )
  		@shifts_task.save
		end
		  if @report = current_user.current_shift.report
        @report.report_items << ReportItem.new(:time => Time.now, :content => "Completed  #{Task.find(@shifts_task.task_id).name} task.", :ip_address => request.remote_ip)
      end
    respond_to do |format|
      format.js
      format.html {redirect_to @report ? @report : @shift_task.data_object}
    end
    # flash[:notice] = 'Task has been completed.'
  end
  
  def update_tasks
    @tasks = Task.in_location(current_user.current_shift.location).after_now
    respond_to do |format|
      format.js
    end
  end


  def display_task_items
    @tasks = ShiftsTask.find_by_task_id(params[:id])
    @start_time = (params[:start_time].nil? ? 3.hours.ago.utc : Time.parse(params[:start_time]))
    respond_to do |format|
      format.js { }
      format.html { } #this is necessary!
    end
     @ShiftsTasks = ShiftsTask.after_time(@start_time).find(:all, :conditions => {:task_id => Task.find(@tasks.task_id)})

  end
  
#TODO: Currently Display Missed Task breaks when given time intervals between tasks larger than a certain amount. The instructions to refactor are below -SP
  def display_missed_task_items
    @tasks = ShiftsTask.find_by_task_id(params[:id])
    @start_time = (params[:start_time].nil? ? 100.hours.ago.utc : Time.parse(params[:start_time]))
    @finish_tasks = ShiftsTask.after_time(@start_time).find(:all, :conditions => {:task_id => Task.find(@tasks.task_id)}) 
    @bad_tasks = []
   if  (@finish_tasks != []) 
    if  (Task.find(@finish_tasks.first.task_id).kind == "Hourly") 
         @timeinterval = 1
     else
       if(Task.find(@finish_tasks.first.task_id).kind == "Daily")
         @timeinterval = 24
       else
        @timeinterval = 168
       end
    end
  else
    @time_interval = 1
  end


    for f in (1..@finish_tasks.size)    
      if  ( (@finish_tasks[f+1].created_at.hour - @finish_tasks[f].created_at.hour) > @timeinterval)

      blame_start_time = Time.utc(@finish_tasks[f].created_at.year, @finish_tasks[f].created_at.mon, @finish_tasks[f].created_at.day, (@finish_tasks[f].created_at.hour + 1), 00, 00)

      blame_end_time =   Time.utc(@finish_tasks[f+1].created_at.year, @finish_tasks[f+1].created_at.mon, @finish_tasks[f+1].created_at.day, @finish_tasks[f+1].created_at.hour, 00, 00)       
     
      @bad_tasks = Shift.find(:all, :conditions => [ 'start < ? OR end < ? OR start > ? OR end > ?', blame_start_time, blame_start_time,  blame_end_time, blame_end_time])
      end     
    end
     
#bracket, time comparisons in sql, do like created at > ? created < ? values that get added would be hour 1 and hour 2. 
    respond_to do |format|
      format.js {}
      format.html { }      
    end    

#Other ways to implement this
##Task.between(time beginnin gof interval, and then time after that said interval)
#So basically from hour 0 which is the time at which the first amount of time is done you take that time and then go from there.
#5.hours.ago.utc.hour. You start then.
#@time 
#for f < time.now.utc.hour 
#you increment f and
#task.between(f, f + 1)
#

#and
# Shift.find(:all, :conditions => { :created_at => (
 #ShiftsTask.find().created_at.hour - anotherone > 1
     #mon, min, day, hour, 
      #Time.utc(samehere, smaemonth, sameday, hour+1, 00, 00)
      #Time.utc(endshift stuff, same, same, same, 00, 00) 
      #Find all shifts within these two times
       #Shift.find(:all, :conditions => [ 'start > ? OR end > ?', blame_end_time, blame_end_time] )        #
    #User.find(Shift.find(@finish_tasks[f].shift_id).user_id).name, 
#Task.find(@finish_tasks[f].task_id).name,
#  @finish_tasks[f].created_at]
   # @ShiftsTasks = @done_tasks.all.find(:all, :conditions => {:task_id => Task.find(:all).each})
  end

  
end