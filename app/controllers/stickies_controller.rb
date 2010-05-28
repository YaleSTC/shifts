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

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @sticky }
    end
  end

  # GET /stickies/1/edit
  def edit
    @sticky = Sticky.find(params[:id])
  end

  # POST /stickies
  # POST /stickies.xml
  def create
    @sticky = Sticky.new(params[:sticky])

    respond_to do |format|
      if @sticky.save
        flash[:notice] = 'Sticky was successfully created.'
        format.html { redirect_to(@sticky) }
        format.xml  { render :xml => @sticky, :status => :created, :location => @sticky }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @sticky.errors, :status => :unprocessable_entity }
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
    @sticky = Sticky.find(params[:id])
    @sticky.destroy

    respond_to do |format|
      format.html { redirect_to(stickies_url) }
      format.xml  { head :ok }
    end
  end
end
