class AnnouncementsController < NoticesController

  def index
    redirect_to(notices_path)
  end

  def show
 		redirect_to(notices_path)
  end

  def new
		current_user.is_loc_group_admin?(current_deparment)
    @announcement = Announcement.new
    layout_check
  end

  def edit
		current_user.is_loc_group_admin?(current_department)
    @announcement = Announcement.find(params[:id])
		layout_check
  end

  def create
		current_user.is_loc_group_admin?(current_department)
    @announcement = Announcement.new(params[:announcement])
		set_author_dept_and_time
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
        flash[:notice] = 'Announcement was successfully created.'
        redirect_to announcements_path
        }
        format.js  #create.js.rjs
      end
    end
  end

  def update
		current_user.is_loc_group_admin?(current_department)
    @announcement = Announcement.find_by_id(params[:id]) || Announcement.new
		@announcement.update_attributes(params[:announcement])
		set_author_dept_and_time
    begin
      Announcement.transaction do
        @announcement.save(false)
        set_sources(@announcement)
        @announcement.save!
      end
    rescue Exception
        respond_to do |format|
          format.html { render :action => "new" }
					format.js
        end
      else
        respond_to do |format|	
        format.html {
          flash[:notice] = 'Announcement was successfully saved.'
          redirect_to :action => "index"
        }
				format.js
      end
    end
  end

  def destroy
		current_user.is_loc_group_admin?(current_department)
    redirect_to :controller => 'notice', :action => 'destroy'
  end

	private
	def set_author_dept_and_time
		@announcement.author = current_user
		@announcement.department = current_department
		@announcement.start_time = Time.now if params[:start_time_choice] == "now"
		if params[:end_time_choice] == "indefinite"
    	@announcement.end_time = nil 
    	@announcement.indefinite = true
		end
	end
end
