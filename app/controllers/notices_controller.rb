class NoticesController < ApplicationController

  before_filter :fetch_loc_groups, :current_user

  # GET /notices
  # GET /notices.xml

  def index
    fetch_loc_groups
    @notices = Notice.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @notices }
    end
  end

  # GET /notices/1
  # GET /notices/1.xml
  def show
    @notice = Notice.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @notice }
    end
  end

  # GET /notices/new
  # GET /notices/new.xml
  def new
    @notice = Notice.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @notice }
    end
  end

  # GET /notices/1/edit
  def edit
    @notice = Notice.find(params[:id])
  end

  # POST /notices
  # POST /notices.xml
  def create

    @notice = Notice.new(params[:notice])
    @notice.author_id = @current_user.id
    @notice.department = @department.id
    @notice.start_time = Time.now if params[:start_time_choice] == 'now' or @notice.is_sticky
    @notice.end_time = nil if params[:end_time_choice] == 'indefinite' or @notice.is_sticky
    @notice.for_locations = params[:for_locations].join(',')
    @notice.for_location_groups = params[:for_location_groups].join(',')
    respond_to do |format|
      if @notice.save
        flash[:notice] = 'Notice was successfully created.'
        format.html { redirect_to(@notice) }
        format.xml  { render :xml => @notice, :status => :created, :location => @notice }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @notice.errors, :status => :unprocessable_entity }
      end
    end

  end

  # PUT /notices/1
  # PUT /notices/1.xml
  def update
    @notice = Notice.find(params[:id])

    respond_to do |format|
      if @notice.update_attributes(params[:notice])
        flash[:notice] = 'Notice was successfully updated.'
        format.html { redirect_to(@notice) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @notice.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /notices/1
  # DELETE /notices/1.xml
  def destroy
    @notice = Notice.find(params[:id])
    @notice.destroy

    respond_to do |format|
      format.html { redirect_to(notices_url) }
      format.xml  { head :ok }
    end
  end

  def fetch_loc_groups
    @loc_groups = @department.loc_groups.all
  end
end

