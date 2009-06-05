class SubRequestsController < ApplicationController
  def index
    @sub_requests = SubRequest.all
  end
  
  def show
    @sub_request = SubRequest.find(params[:id])
  end
  
  def new
    @sub_request = SubRequest.new
  end
  
  def create
    @sub_request = SubRequest.new(params[:sub_request])
    if @sub_request.save
      flash[:notice] = "Successfully created subrequest."
      redirect_to @sub_request
    else
      render :action => 'new'
    end
  end
  
  def edit
    @sub_request = SubRequest.find(params[:id])
  end
  
  def update
    @sub_request = SubRequest.find(params[:id])
    if @sub_request.update_attributes(params[:sub_request])
      flash[:notice] = "Successfully updated subrequest."
      redirect_to @sub_request
    else
      render :action => 'edit'
    end
  end
  
  def destroy
    @sub_request = SubRequest.find(params[:id])
    @sub_request.destroy
    flash[:notice] = "Successfully destroyed subrequest."
    redirect_to sub_requests_url
  end
end
