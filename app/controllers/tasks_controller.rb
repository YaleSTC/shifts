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
    @tasks = Task.in_location(current_user.current_shift.location).after_now.delete_if{|t| t.kind == "Weekly" && t.day_in_week != @shift.start.strftime("%a")}

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
    # flash[:notice] = 'Task has been completed.'
  end
  
  def update_tasks
    @shift = current_user.current_shift
    @tasks = Task.in_location(current_user.current_shift.location).after_now.delete_if{|t| t.kind == "Weekly" && t.day_in_week != @shift.start.strftime("%a")}
    respond_to do |format|
      format.js
    end
  end


  def completed_tasks
    @tasks = ShiftsTask.find_by_task_id(params[:id])
    @completed_tasks = ShiftsTask.find(:all, :conditions => {:task_id => Task.find(@tasks.task_id), :missed => false})
  end
  
  def missed_tasks
    @tasks = ShiftsTask.find_by_task_id(params[:id])
    #@missed = ShiftsTask.find(:all, :conditions => {:task_id => Task.find(@tasks.task_id)})
    #@missed_tasks = []
    #@missed.each do |task|
    #  if task.task.done
    #    @missed_tasks << task
    #  end
    #end
  #  @missed_tasks
  #end
    @completed_tasks = ShiftsTask.find(:all, :conditions => {:task_id => Task.find(@tasks.task_id), :missed => true})
  end
  
  
end