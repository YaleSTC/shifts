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
    @notice.is_sticky = true unless current_user.is_admin_of?(@department)
    @notice.author = current_user
    @notice.department = @department
    @notice.start_time = Time.now if @notice.is_sticky
    @notice.end_time = nil if params[:indefinite] || @notice.is_sticky
    params[:for_users].split(",").map(&:strip).each do |login_or_name|
    viewer = User.find_by_login(login_or_name) || User.find_by_name(login_or_name)
    if viewer
      @notice.add_viewer_source(viewer)
    else
      @notice.errors.add_to_base "\'#{login_or_name}\' is not a valid name or NetID." unless login_or_name.blank?
    end
  end
    @notice.add_display_location_source(@department) if params[:department_wide_locations] && current_user.is_admin_of?(@department)
    if params[:for_locations]
      params[:for_locations].each do |loc|
        @notice.add_display_location_source(Location.find_by_id(loc))
      end
    end
    if params[:for_location_groups]
      params[:for_location_groups].each do |loc_group|
        @notice.add_display_location_source(LocGroup.find_by_id(loc_group))
      end
    end
    respond_to do |format|
      if @notice.save
        flash[:notice] = 'Notice was successfully created.'
        format.html { redirect_to (request.referer) }
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

  # DELETE /notices/1_id
  # DELETE /notices/1.xml
  def destroy
    @notice = Notice.find(params[:id])
    unless @notice.is_sticky || current_user.is_admin_of?(@notice.department)
      redirect_with_flash("You are not authorized to remove this notice", :back) and return
    end
    unless @notice.is_current?
      redirect_with_flash("This notice was already removed on #{@notice.end_time}", :back) and return
    end
    redirect_with_flash("Notice successfully removed", :back) if @notice.remove(current_user)
    @notice.save!
  end

  def fetch_loc_groups
    @loc_groups = @department.loc_groups.all
  end
end

