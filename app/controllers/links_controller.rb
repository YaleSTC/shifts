class LinksController < NoticesController

  def index
    redirect_to(notices_path)
  end


  def new
    @link = Link.new
		layout_check
  end

  def edit
    @link = Link.find(params[:id])
  end

  def create
    @link = Link.new(params[:link])
		@link.author = current_user		
		@link.url = "http://" << params[:link][:url] if @link.url[0,7] != "http://" || @link.url[0,8] != "https://"
		@link.start_time = Time.now
    @link.end_time = nil
    @link.indefinite = true
		begin
      Link.transaction do
        @link.save(false)
        set_sources(@link)
        @link.save!
    	end
		rescue Exception
      respond_to do |format|
        format.html { render :action => "new" }
        format.js  #create.js.rjs
      end
    else
      respond_to do |format|
        format.html {
        flash[:notice] = 'Link was successfully created.'
        redirect_to links_path
        }
        format.js  #create.js.rjs
      end
    end
  end

  def destroy
		redirect_to :controller => 'notice', :action => 'destroy'
  end
end
