class AnnouncementsController < NoticesController

  def index
    redirect_to(notices_path)
  end

  def show
 		redirect_to(notices_path)
  end

  def new
    @announcement = Announcement.new
    layout_check
  end

  def edit
    @announcement = Announcement.find(params[:id])
		layout_check
  end

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
		@announcement.update_attributes(params[:announcement])
    begin
      Announcement.transaction do
        @announcement.save(false)
        set_sources(@announcement)
        @announcement.save!
      end
    rescue Exception
        respond_to do |format|
          format.html { render :action => "edit" }
          format.js  #update.js.rjs
        end
      else
        respond_to do |format|
        format.html {
          flash[:notice] = 'Announcement was successfully saved.'
          redirect_to :action => "index"
        }
        format.js  #update.js.rjs
      end
    end
  end

  def destroy
    redirect_to :controller => 'notice', :action => 'destroy'
  end
end
