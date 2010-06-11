class AnnouncementsController < NoticesController

  def index
    redirect_to(notices_path)
  end

  def show
    @announcement = Announcement.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @announcement }
    end
  end

  def new
    @announcement = Announcement.new
    layout_check
  end

  def edit
    @announcement = Announcement.find(params[:id])
  end

  def create
    @announcement = Announcement.new(params[:announcement])
		raise params.to_yaml
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
        format.html {
        flash[:sticky] = 'Announcement was successfully created.'
        redirect_to announcements_path
        }
        format.js  #create.js.rjs
      end
    end
  end

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

  def destroy
    redirect_to :controller => 'notice', :action => 'destroy'
  end
end
