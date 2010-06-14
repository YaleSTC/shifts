class SubRequestsController < ApplicationController

# Any reason at all why we should leave this in? -ben
# Yes: for users without Javascript. -ryan
  def index
    @sub_requests = (params[:shift_id] ? Shift.find(params[:shift_id]).sub_requests : SubRequest.all)
  end

  def show
    @sub_request = SubRequest.find(params[:id])
    return unless user_is_owner_or_admin_of(@sub_request.shift, current_department)
  end

  def new
    @sub_request = SubRequest.new
    @sub_request.shift = Shift.find(params[:shift_id])
    return unless user_is_owner_or_admin_of(@sub_request.shift, current_department)
  end

  def edit
    @sub_request = SubRequest.find(params[:id])
    return unless user_is_owner_or_admin_of(@sub_request.shift, current_department)
  end

  def create
    @sub_request = SubRequest.new(params[:sub_request])
    @sub_request.shift = Shift.find(params[:shift_id])
    @sub_request.user = @sub_request.shift.user
    begin
      SubRequest.transaction do  
          @sub_request.save(false)
          if !params[:list_of_logins].empty? 
             params[:list_of_logins].split(",").each do |l|
                l = l.split("||")
                @sub_request.user_sources << l[0].constantize.find(l[1]) if l.length == 2
                @sub_request.user_sources << User.find_by_login(l[0]) if l.length == 1
             end
           end
        @sub_request.save!
      end
    rescue Exception => e
      @sub_request = @sub_request.clone
      @sub_request.add_errors(e.message)
      render :action => "new"
    else
      flash[:notice] = 'Sub request was successfully created.'
    #  @sub_request.potential_takers.each do |user|
        # "if user.email" because email is not a compulsory field in user
     #   ArMailer.deliver(ArMailer.create_sub_created_notify user.email, @sub_request) if user.email
     # end
      redirect_to :action => "show", :id => @sub_request
    end
  end

  def update
    @sub_request = SubRequest.find(params[:id])
    return unless user_is_owner_or_admin_of(@sub_request.shift, current_department)
    begin
      SubRequest.transaction do
          UserSinksUserSource.delete_all("user_sink_type= 'SubRequest' AND user_sink_id = #{@sub_request.id.to_sql}")
          if !params[:list_of_logins].empty? 
            params[:list_of_logins].split(",").each do |l|
              l = l.split("||")
              @sub_request.user_sources << l[0].constantize.find(l[1]) if l.length == 2
              @sub_request.user_sources << User.find_by_login(l[0]) if l.length == 1
            end
          end
          @sub_request.update_attributes(params[:sub_request])
          @sub_request.save!
        end
      rescue Exception => e
        @sub_request = @sub_request.clone
        @sub_request.add_errors(e.message)
        render :action => "edit", :id => @sub_request
      else
        flash[:notice] = 'SubRequest was successfully updated.'
        redirect_to :action => "show", :id => @sub_request       
      end
  end

  def destroy
    @sub_request = SubRequest.find(params[:id])
    return unless user_is_owner_or_admin_of(@sub_request.shift, current_department)
    @sub_request.destroy
    UserSinksUserSource.delete_all("user_sink_type = 'SubRequest' AND user_sink_id = #{params[:id].to_sql}")
    flash[:notice] = "Successfully destroyed sub request."
    redirect_to sub_requests
  end

  def get_take_info
    begin
      @sub_request = SubRequest.find(params[:id])
      if !@sub_request.user_is_eligible?(current_user)
         flash.now[:error] = "Access Denied.  You do not have permission to take that sub_request."
       end
    rescue
      flash.now[:error] = "Oops! It seems the Sub Request you tried to take has already been taken (or canceled). Next time, try clicking sooner!"
    end

  end

  def take
    @sub_request = SubRequest.find(params[:id])
    return unless require_department_membership(@sub_request.shift.department)
    #The form returns string values of "true" or "false", we must convert these to boolean
    just_mandatory = params[:sub_request][:mandatory_start] == "true" ? true : false
    begin
      SubRequest.take(@sub_request, current_user, just_mandatory)
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

