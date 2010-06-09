class AnnouncementsController < NoticesController
  # GET /announcements
  # GET /announcements.xml
  def index
    @announcements = Announcement.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @announcements }
    end
  end

  # GET /announcements/1
  # GET /announcements/1.xml
  def show
    @announcement = Announcement.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @announcement }
    end
  end

  # GET /announcements/new
  # GET /announcements/new.xml
  def new
    @announcement = Announcement.new

    layout_check
  end

  # GET /announcements/1/edit
  def edit
    @announcement = Announcement.find(params[:id])
  end

  # POST /announcements
  # POST /announcements.xml
  def create
    @announcement = Announcement.new(params[:announcement])
		@announcement.author = current_user
		@announcement.start_time = Time.now if params[:start_time_choice] == "now"
    @announcement.end_time = nil if params[:end_time_choice] == "indefinite"
    @announcement.indefinite = true if params[:end_time_choice] == "indefinite"
		begin
      Announcement.transaction do
        @announcement.save(false)
        set_sources(@announcement)
        @announcement.save!
    	end
		rescue Exception
			respond_to do |format|
        format.html { render :action => "new" }
        format.js  #create.js.rjs
      end
		else
		  respond_to do |format|
		    if @announcement.save
		      flash[:notice] = 'Announcement was successfully created.'
		      format.html { redirect_to(@announcement) }
		      format.xml  { render :xml => @announcement, :status => :created, :location => @announcement }
		    else
		      format.html { render :action => "new" }
		      format.xml  { render :xml => @announcement.errors, :status => :unprocessable_entity }
		    end
		  end
		end
  end

  # PUT /announcements/1
  # PUT /announcements/1.xml
  def update
    @announcement = Announcement.find(params[:id])

    respond_to do |format|
      if @announcement.update_attributes(params[:announcement])
        flash[:notice] = 'Announcement was successfully updated.'
        format.html { redirect_to(@announcement) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @announcement.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /announcements/1
  # DELETE /announcements/1.xml
  def destroy
    redirect_to :controller => 'notice', :action => 'destroy'
  end
end
