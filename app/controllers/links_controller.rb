class LinksController < NoticesController
  # GET /links
  # GET /links.xml
  def index
    @links = Link.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @links }
    end
  end

  # GET /links/1
  # GET /links/1.xml
  def show
    @link = Link.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @link }
    end
  end

  # GET /links/new
  # GET /links/new.xml
  def new
    @link = Link.new


		layout_check
  end

  # GET /links/1/edit
  def edit
    @link = Link.find(params[:id])
  end

  # POST /links
  # POST /links.xml
  def create
    @link = Link.new(params[:link])
# raise params.to_yaml
		@link.author = current_user
		@link.url = params[:url]
    @link.content = params[:link_label]
		#raise params.to_yaml
		@link.content.gsub!("http://https://", "https://")
    @link.content.gsub!("http://http://", "http://")
    
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
        flash[:notice] = 'Notice was successfully created.'
        redirect_to notices_path
        }
        format.js  #create.js.rjs
      end
    end
  end

  # PUT /links/1
  # PUT /links/1.xml
  def update
    @link = Link.find(params[:id])

    respond_to do |format|
      if @link.update_attributes(params[:link])
        flash[:notice] = 'Link was successfully updated.'
        format.html { redirect_to(@link) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @link.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /links/1
  # DELETE /links/1.xml
  def destroy
		redirect_to :controller => 'notice', :action => 'destroy'
  end
end
