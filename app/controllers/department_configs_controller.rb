class DepartmentConfigsController < ApplicationController
  before_filter :check_user

  # GET /department_configs
  # GET /department_configs.xml
#  def index
#    @department_configs = DepartmentConfig.all
#    respond_to do |format|
#      format.html # index.html.erb
#      format.xml  { render :xml => @department_configs }
#    end
#  end

  # GET /department_configs/1
  # GET /department_configs/1.xml
#  def show
#    @department_config = DepartmentConfig.find(params[:id])

#    respond_to do |format|
#      format.html # show.html.erb
#      format.xml  { render :xml => @department_config }
#    end
#  end

  # GET /department_configs/new
  # GET /department_configs/new.xml
#  def new
#    #@department_config = DepartmentConfig.new
#    @department_config = DepartmentConfig.default
#    @time_choices = (0..1440).step(@department_config.time_increment).map{|t| [t.min_to_am_pm, t]}
#    @select_dept = Department.all.map{|d| [d.name, d.id.to_s]}
#    if params[:department_config]
#      if @department_config.nil?
#        @department_config = DepartmentConfig.default
#      end
#    end

#    respond_to do |format|
#      format.html # new.html.erb
#      format.xml  { render :xml => @department_config }
#    end
#  end

  # GET /department_configs/1/edit
  def edit
    @select_dept = DepartmentConfig.find(params[:id]).department.name
    @department_config = DepartmentConfig.find(params[:id])
    @time_choices = (0..1440).step(@department_config.time_increment).map{|t| [t.min_to_am_pm, t]}
  end
#    raise params.to_yaml
  # POST /department_configs
  # POST /department_configs.xml
#  def create
##    raise params.to_yaml
#    @department_config = DepartmentConfig.new(params[:department_config])
##    @department_config.department_id = Department.find_by_name(params[:department_id])

#    respond_to do |format|
#      if @department_config.save
#        flash[:notice] = 'DepartmentConfig was successfully created.'
#        format.html { redirect_to(@department_config) }
#        format.xml  { render :xml => @department_config, :status => :created, :location => @department_config }
#      else
#        format.html { render :action => "new" }
#        format.xml  { render :xml => @department_config.errors, :status => :unprocessable_entity }
#      end
#    end
#  end

  # PUT /department_configs/1
  # PUT /department_configs/1.xml
  def update
#    respond_to do |format|
      if @department_config.update_attributes(params[:department_config])
        flash[:notice] = "Successfully updated department settings."
        redirect_to (params[:redirect_to] ? params[:redirect_to] : edit_department_config_path)
#        format.html { redirect_to(@department_config) }
#        format.xml  { head :ok }
      else
        render :action => 'edit'
#        format.html { render :action => "edit" }
#        format.xml  { render :xml => @department_config.errors, :status => :unprocessable_entity }
      end
#    end
  end

  # DELETE /department_configs/1
  # DELETE /department_configs/1.xml
#  def destroy
#    @department_config = DepartmentConfig.find(params[:id])
#    @department_config.destroy

#    respond_to do |format|
#      format.html { redirect_to(department_configs_url) }
#      format.xml  { head :ok }
#    end
#  end

private

  def check_user
    @department_config = DepartmentConfig.find(params[:id])
    unless  current_user.is_superuser?
      flash[:error] = "You do not have the authority to edit department settings."
      redirect_to root_path
    end
  end
end

