class SubRequestsController < ApplicationController

# Any reason at all why we should leave this in? -ben
# Yes: for users without Javascript. -ryan
  def index
    @sub_requests = (params[:shift_id] ? Shift.find(params[:shift_id]).sub_requests : SubRequest.all)
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
    @sub_request.user = @sub_request.shift.user
    begin
      SubRequest.transaction do
        @sub_request.save(false)
        params[:list_of_logins].split(",").each do |l|
          l = l.split("||")
          @sub_request.user_sources << l[0].constantize.find(l[1]) if l.length == 2
          @sub_request.user_sources << User.find_by_login(l[0]) if l.length == 1
        end
        @sub_request.save!
      end
    rescue Exception => e
      @sub_request = @sub_request.clone
      @sub_request.add_errors(e.message)
      render :action => "new"
      #redirect_to :action => :new, :id => @sub_request.shift
    else
      flash[:notice] = 'Sub request was successfully created.'
      @sub_request.potential_takers.each do |user|
        # "if user.email" because email is not a compulsory field in user
        ArMailer.deliver(ArMailer.create_sub_created_notify user.email, @sub_request) if user.email
      end
      redirect_to :action => "show", :id => @sub_request
    end


#    if @sub_request.save
#      flash[:notice] = 'Sub request was successfully created.'
#      redirect_to @sub_request
#    else
#      render :action => "new"
#    end
  end

  def update
    @sub_request = SubRequest.find(params[:id])
    #TODO This should probably be in a transaction, so that
    #if the update fails all sub sources don't get deleted...
    return unless require_owner_or_dept_admin(@sub_request.shift, current_department)
    UserSinksUserSource.delete_all("user_sink_type= 'SubRequest' AND user_sink_id = #{@sub_request.id.to_sql}")
    params[:list_of_logins].split(",").each do |l|
      l = l.split("||")
      @sub_request.user_sources << l[0].constantize.find(l[1]) if l.length == 2
      @sub_request.user_sources << User.find_by_login(l[0]) if l.length == 1
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
    UserSinksUserSource.delete_all("user_sink_type = 'SubRequest' AND user_sink_id = #{params[:id].to_sql}")
    flash[:notice] = "Successfully destroyed sub request."
    redirect_to dashboard_url
  end

  def get_take_info
    @sub_request = SubRequest.find(params[:id])
  end

  def take
    @sub_request = SubRequest.find(params[:id])
    return unless require_department_membership(@sub_request.shift.department)
    begin
      SubRequest.take(@sub_request, current_user, params[:mandatory_start])
        flash[:notice] = 'Sub request was successfully taken.'
        redirect_to dashboard_path

    rescue Exception => e
      if !@sub_request.user_is_eligible?(current_user)
        flash[:error] = 'You are not authorized to take this shift'
      else
        flash[:error] = e.message.gsub("Validation failed: ", "")
      end
      render :action => "get_take_info"
     end
  end
end

