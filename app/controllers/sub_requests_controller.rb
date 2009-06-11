class SubRequestsController < ApplicationController
  # GET /sub_requests
  # GET /sub_requests.xml
  def index
    @sub_requests = SubRequest.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @sub_requests }
    end
  end

  # GET /sub_requests/1
  # GET /sub_requests/1.xml
  def show
    @sub_request = SubRequest.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @sub_request }
    end
  end

  # GET /sub_requests/new
  # GET /sub_requests/new.xml
  def new
    @sub_request = SubRequest.new
    @sub_request.shift = Shift.find(params[:shift_id])
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @sub_request }
    end
  end

  # GET /sub_requests/1/edit
  def edit
    @sub_request = SubRequest.find(params[:id])
  end

  # POST /sub_requests
  # POST /sub_requests.xml
  def create
    @sub_request = SubRequest.new(params[:sub_request])
    @sub_request.shift = Shift.find(params[:shift_id])
    params[:list_of_logins].split(/\W+/).each do |l|
      @sub_request.add_substitute_source(User.find_by_login(l))
    end


    respond_to do |format|
      if @sub_request.save
        flash[:notice] = 'Sub request was successfully created.'
        format.html { redirect_to(@sub_request) }
        format.xml  { render :xml => @sub_request, :status => :created, :location => @sub_request }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @sub_request.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /sub_requests/1
  # PUT /sub_requests/1.xml
  def update
    @sub_request = SubRequest.find(params[:id])
    #TODO This should probably be in a transaction, so that
    #if the update fails all sub sources don't get deleted...
    @sub_request.remove_all_substitute_sources
    params[:list_of_logins].split(/\W+/).each do |l|
      @sub_request.add_substitute_source(User.find_by_login(l))
    end
    respond_to do |format|
      if @sub_request.update_attributes(params[:sub_request])
        flash[:notice] = 'SubRequest was successfully updated.'
        format.html { redirect_to(@sub_request) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @sub_request.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /sub_requests/1
  # DELETE /sub_requests/1.xml
  def destroy
    @sub_request = SubRequest.find(params[:id])
    @sub_request.destroy

    respond_to do |format|
      format.html { redirect_to(sub_requests_url) }
      format.xml  { head :ok }
    end
  end

  def get_take_info
    @sub_request = SubRequest.find(params[:id])
  end

  def take
    @sub_request = SubRequest.find(params[:id])
    if SubRequest.take(@sub_request, current_user, params[:just_mandatory])
      redirect_to(shifts_path)
    else
      flash[:notice] = 'You are not authorized to take this shift'
      redirect_to(get_take_info_sub_request_path(@sub_request))
    end
  end

end

