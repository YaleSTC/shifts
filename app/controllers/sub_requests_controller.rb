class SubRequestsController < ApplicationController

  def index
    @sub_requests = SubRequest.all
  end

  def show
    @sub_request = SubRequest.find(params[:id])
  end

  def new
    @sub_request = SubRequest.new
    @sub_request.shift = Shift.find(params[:shift_id])
    return unless require_owner_or_dept_admin(@sub_request.shift, current_department)
  end

  def edit
    @sub_request = SubRequest.find(params[:id])
    return unless require_owner_or_dept_admin(@sub_request.shift, current_department)
  end

  def create
    @sub_request = SubRequest.new(params[:sub_request])
    @sub_request.shift = Shift.find(params[:shift_id])
    @sub_request.save! #TODO: need to save before adding polymorphisms -- sorry!
    params[:list_of_logins].split(",").each do |l|
      l = l.split("||")
      @sub_request.user_sources << l[0].constantize.find(l[1]) if l.length == 2
    end
    if @sub_request.save
      flash[:notice] = 'Sub request was successfully created.'
      redirect_to @sub_request
    else
      render :action => "new"
    end
  end

  def update
    @sub_request = SubRequest.find(params[:id])
    #TODO This should probably be in a transaction, so that
    #if the update fails all sub sources don't get deleted...
    return unless require_owner_or_dept_admin(@sub_request.shift, current_department)
    @sub_request.user_sources = []
    params[:list_of_logins].split(",").each do |l|
      l = l.split("||")
      @sub_request.user_sources << l[0].constantize.find(l[1]) if l.length == 2
    end
    if @sub_request.update_attributes(params[:sub_request])
      flash[:notice] = 'SubRequest was successfully updated.'
      redirect_to @sub_request
    else
      render :action => "edit"
    end
  end

  def destroy
    @sub_request = SubRequest.find(params[:id])
    return unless require_owner_or_dept_admin(@sub_request.shift, current_department)
    @sub_request.destroy
    flash[:notice] = "Successfully destroyed sub request."
    redirect_to shifts_url
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

