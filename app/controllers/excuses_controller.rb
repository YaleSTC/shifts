class ExcusesController < ApplicationController
  # GET /excuses
  # GET /excuses.xml
  def index
    @excuses = Excuse.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @excuses }
    end
  end

  # GET /excuses/1
  # GET /excuses/1.xml
  def show
    @excuse = Excuse.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @excuse }
    end
  end

  # GET /excuses/new
  # GET /excuses/new.xml
  def new
    @excuse = Excuse.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @excuse }
    end
  end

  # GET /excuses/1/edit
  def edit
    @excuse = Excuse.find(params[:id])
  end

  # POST /excuses
  # POST /excuses.xml
  def create
    @excuse = Excuse.new(params[:excuse])

    respond_to do |format|
      if @excuse.save
        format.html { redirect_to(@excuse, :notice => 'Excuse was successfully created.') }
        format.xml  { render :xml => @excuse, :status => :created, :location => @excuse }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @excuse.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /excuses/1
  # PUT /excuses/1.xml
  def update
    @excuse = Excuse.find(params[:id])

    respond_to do |format|
      if @excuse.update_attributes(excused: params[:excused])
        format.html { redirect_to(excuses_url) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @excuse.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /excuses/1
  # DELETE /excuses/1.xml
  def destroy
    @excuse = Excuse.find(params[:id])
    @excuse.destroy

    respond_to do |format|
      format.html { redirect_to(excuses_url) }
      format.xml  { head :ok }
    end
  end
end
