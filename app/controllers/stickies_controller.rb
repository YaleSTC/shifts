class StickiesController < NoticesController
  # GET /stickies
  # GET /stickies.xml
  def index
    @stickies = Sticky.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @stickies }
    end
  end

  # GET /stickies/1
  # GET /stickies/1.xml
  def show
    @sticky = Sticky.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @sticky }
    end
  end

  # GET /stickies/new
  # GET /stickies/new.xml
  def new
    @sticky = Sticky.new

    layout_check
  end

  # GET /stickies/1/edit
  def edit
    @sticky = Sticky.find(params[:id])
  end

  # POST /stickies
  # POST /stickies.xml
  def create
    @sticky = Sticky.new(params[:sticky])
		@sticky.author = current_user
		@sticky.start_time = Time.now
		if params[:end_time_choice] == "indefinite"
			@sticky.end_time = nil
			@sticky.indefinite = true
		elsif params[:sticky][:end_time] == "day"
			@sticky.end_time = @sticky.start_time + 86400
		elsif params[:sticky][:end_time] == "week"
			@sticky.end_time = @sticky.start_time + 604800
		elsif params[:sticky][:end_time] == "month"
			@sticky.end_time = @sticky.start_time + 18144000
		end
		begin
      Sticky.transaction do
        @sticky.save(false)
        set_sources(@sticky)
        @sticky.save!
    	end
		rescue Exception
      respond_to do |format|
        format.html { render :action => "new" }
        format.js  #create.js.rjs
      end
    else
      respond_to do |format|
        format.html {
        flash[:sticky] = 'Sticky was successfully created.'
        redirect_to stickies_path
        }
        format.js  #create.js.rjs
      end
    end
  end

  # PUT /stickies/1
  # PUT /stickies/1.xml
  def update
    @sticky = Sticky.find(params[:id])

    respond_to do |format|
      if @sticky.update_attributes(params[:sticky])
        flash[:notice] = 'Sticky was successfully updated.'
        format.html { redirect_to(@sticky) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @sticky.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /stickies/1
  # DELETE /stickies/1.xml
  def destroy
		redirect_to :controller => 'notice', :action => 'destroy'
	end
end
