class NoticesController < ApplicationController

  before_filter :fetch_loc_groups
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
#    raise params.to_yaml
    @notice = Notice.new(params[:notice])
    @notice.author = current_user
    @notice.start_time = Time.now if @notice.is_sticky
    @notice.end_time = nil if params[:indefinite] || @notice.is_sticky
    params[:for_users].split(/\W+/).each do |l|
      @notice.add_viewer_source(User.find_by_login(l))
    end
    @notice.add_display_location_source(@department) if params[:department_wide] && current_user.is_admin_of?(@department)
    @notice.add_viewer_source(@department) if params[:department_wide_users] && current_user.is_admin_of?(@department)
#    @notice.for_locations = params[:for_locations].join(',') if params[:for_locations]
#    @notice.for_location_groups = params[:for_location_groups].join(',') if params[:for_location_groups]
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
