class TemplatesController < ApplicationController
  before_filter :require_department_admin
  layout "application"
  # GET /templates
  # GET /templates.xml
  def index
    @week_templates = Template.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @week_templates }
    end
  end

  # GET /templates/1
  # GET /templates/1.xml
  def show
    @week_template = Template.find(params[:id])
		@requested_shifts = @week_template.requested_shifts
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @week_template }
    end
  end

  # GET /templates/new
  # GET /templates/new.xml
  def new
    @week_template = Template.new
		@locations = current_department.locations
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @week_template }
    end
  end

  # GET /templates/1/edit
  def edit
    @week_template = Template.find(params[:id])
  end

  # POST /templates
  # POST /templates.xml
  def create
    @week_template = Template.new(params[:template])
		if params[:for_locations]
			@week_template.locations << Location.find(params[:for_locations])
    end
		respond_to do |format|
      if @week_template.save
        flash[:notice] = 'Template was successfully created.'
        format.html { redirect_to(@week_template) }
        format.xml  { render :xml => @week_template, :status => :created, :location => @week_template }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @week_template.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /templates/1
  # PUT /templates/1.xml
  def update
    @week_template = Template.find(params[:id])

    respond_to do |format|
      if @week_template.update_attributes(params[:template])
        flash[:notice] = 'Template was successfully updated.'
        format.html { redirect_to(@week_template) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @week_template.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /templates/1
  # DELETE /templates/1.xml
  def destroy
    @week_template = Template.find(params[:id])
    @week_template.destroy

    respond_to do |format|
      format.html { redirect_to(templates_url) }
      format.xml  { head :ok }
    end
  end
end
