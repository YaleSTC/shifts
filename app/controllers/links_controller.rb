class LinksController < NoticesController
	before_filter :require_any_loc_group_admin, :except => [:index, :show, :destroy]

  def new
		@current_shift_location = current_user.current_shift.location if current_user.current_shift
    @link = Link.new
		layout_check
  end

  def edit
    @link = Link.find(params[:id])
  end

  def create
    @link = Link.new(params[:link])
		@link.author = current_user		
		@link.department = current_department
		@link.url = "http://" << params[:link][:url] if @link.url[0,7] != "http://" && @link.url[0,8] != "https://"
		@link.url.strip!
		@link.start = Time.now
    @link.end = nil
    @link.indefinite = true
    current_user.current_shift ? @current_shift = current_user.current_shift : nil
		begin
      Link.transaction do
        @link.save(false)
        set_sources(@link)
        @link.save!
    	end
		rescue ActiveRecord::RecordInvalid
      respond_to do |format|
        format.html { render :action => "new" }
        format.js  #create.js.rjs
      end
    else
      respond_to do |format|
        flash[:notice] = 'Link was successfully created.'
        format.html {
        redirect_to links_path
        }
        format.js  #create.js.rjs
      end
    end
  end

	def update
    @link = Link.where(:id == params[:id]).first || Link.new
    @link.update_attributes(params[:link])
		@link.author = current_user		
		@link.department = current_department
		@link.url = "http://" << params[:link][:url] if @link.url[0,7] != "http://" && @link.url[0,8] != "https://"
		@link.url.strip!
		@link.start = Time.now
    @link.end = nil
    @link.indefinite = true
		begin
      Link.transaction do
        @link.save(false)
        set_sources(@link)
        @link.save!
    	end
		rescue ActiveRecord::RecordInvalid
      respond_to do |format|
        format.html { render :action => "new" }
      end
    else
      respond_to do |format|
        format.html {
        flash[:notice] = 'Link was successfully created.'
        redirect_to links_path
        }
      end
    end
  end
end
