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

    respond_to do |format|
      if @sub_request.save
        flash[:notice] = 'SubRequest was successfully created.'
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
end
