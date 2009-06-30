class DepartmentConfigsController < ApplicationController
  # GET /department_configs
  # GET /department_configs.xml
  def index
    @department_configs = DepartmentConfig.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @department_configs }
    end
  end

  # GET /department_configs/1
  # GET /department_configs/1.xml
  def show
    @department_config = DepartmentConfig.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @department_config }
    end
  end

  # GET /department_configs/new
  # GET /department_configs/new.xml
  def new
    @department_config = DepartmentConfig.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @department_config }
    end
  end

  # GET /department_configs/1/edit
  def edit
    @department_config = DepartmentConfig.find(params[:id])
  end

  # POST /department_configs
  # POST /department_configs.xml
  def create
    @department_config = DepartmentConfig.new(params[:department_config])

    respond_to do |format|
      if @department_config.save
        flash[:notice] = 'DepartmentConfig was successfully created.'
        format.html { redirect_to(@department_config) }
        format.xml  { render :xml => @department_config, :status => :created, :location => @department_config }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @department_config.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /department_configs/1
  # PUT /department_configs/1.xml
  def update
    @department_config = DepartmentConfig.find(params[:id])

    respond_to do |format|
      if @department_config.update_attributes(params[:department_config])
        flash[:notice] = 'DepartmentConfig was successfully updated.'
        format.html { redirect_to(@department_config) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @department_config.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /department_configs/1
  # DELETE /department_configs/1.xml
  def destroy
    @department_config = DepartmentConfig.find(params[:id])
    @department_config.destroy

    respond_to do |format|
      format.html { redirect_to(department_configs_url) }
      format.xml  { head :ok }
    end
  end
end

