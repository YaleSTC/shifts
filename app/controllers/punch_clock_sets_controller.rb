class PunchClockSetsController < ApplicationController
  # GET /punch_clock_sets
  # GET /punch_clock_sets.xml
  def index
    @punch_clock_sets = PunchClockSet.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @punch_clock_sets }
    end
  end

  # GET /punch_clock_sets/1
  # GET /punch_clock_sets/1.xml
  def show
    @punch_clock_set = PunchClockSet.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @punch_clock_set }
    end
  end

  # GET /punch_clock_sets/new
  # GET /punch_clock_sets/new.xml
  def new
    @punch_clock_set = PunchClockSet.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @punch_clock_set }
    end
  end

  # GET /punch_clock_sets/1/edit
  def edit
    @punch_clock_set = PunchClockSet.find(params[:id])
  end

  # POST /punch_clock_sets
  # POST /punch_clock_sets.xml
  def create
    @punch_clock_set = PunchClockSet.new(params[:punch_clock_set])

    respond_to do |format|
      if @punch_clock_set.save
        flash[:notice] = 'PunchClockSet was successfully created.'
        format.html { redirect_to(@punch_clock_set) }
        format.xml  { render :xml => @punch_clock_set, :status => :created, :location => @punch_clock_set }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @punch_clock_set.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /punch_clock_sets/1
  # PUT /punch_clock_sets/1.xml
  def update
    @punch_clock_set = PunchClockSet.find(params[:id])

    respond_to do |format|
      if @punch_clock_set.update_attributes(params[:punch_clock_set])
        flash[:notice] = 'PunchClockSet was successfully updated.'
        format.html { redirect_to(@punch_clock_set) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @punch_clock_set.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /punch_clock_sets/1
  # DELETE /punch_clock_sets/1.xml
  def destroy
    @punch_clock_set = PunchClockSet.find(params[:id])
    @punch_clock_set.destroy

    respond_to do |format|
      format.html { redirect_to(punch_clock_sets_url) }
      format.xml  { head :ok }
    end
  end
end
