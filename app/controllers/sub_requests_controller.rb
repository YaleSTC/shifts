class SubRequestsController < ApplicationController

  def index
    if params[:shift_id]      # check if index listing is shift specific
      @shift=Shift.find(params[:shift_id])
      @subs=@shift.sub_requests 
      @title_add=" for " + @shift.user.name + "'s shift in " + @shift.location.name + " on " + @shift.start.to_s(:gg)
      @index_link = true
    else                      
      @subs = SubRequest.find(:all, :conditions => ["end >= ?", Time.now])
      @title_add=" Index"
      @index_link=false
    end
    @subs = @subs.select {|sub| (current_user.can_take_sub?(sub) || current_user.is_admin_of?(sub.shift.department) || sub.user == current_user)} 

    @limit = (params[:limit].blank? ? 25 : params[:limit].to_i)
    if @limit<@subs.count
      @limit_links=true
    else
      @limit_links=false
      @limit=@subs.count
    end
  end

  def show
    @sub_request = SubRequest.find(params[:id])
    @sub_request.user_is_eligible?(current_user) || user_is_owner_or_admin_of(@sub_request.shift, current_department)
    #if user_is_own_or_admin_of fails, it will redirect away from page w/ associated error message.
  end

  def new
    @sub_request = SubRequest.new(:shift_id => params[:shift_id])
    @sub_request.mandatory_end = @sub_request.end = @sub_request.shift.end
    return unless user_is_owner_or_admin_of(@sub_request.shift, current_department)    #is 'return unless' unnessecary here? -Bay
  end

  def edit
    @sub_request = SubRequest.find(params[:id])
    return unless user_is_owner_or_admin_of(@sub_request.shift, current_department)        #is 'return unless' unnessecary here? -Bay
  end

  def create
    parse_date_and_time_output(params[:sub_request])
    @sub_request = SubRequest.new(params[:sub_request])
    @sub_request.shift = Shift.find(params[:shift_id])
    unless params[:list_of_logins].empty? 
      params[:list_of_logins].split(",").each do |l|
        l = l.split("||")
        if l.length == 2
          for user in l[0].constantize.find(l[1]).users 
            @sub_request.requested_users << user
          end
        end
        @sub_request.requested_users << User.find_by_login(l[0]) if l.length == 1
      end
    end
    unless @sub_request.save
      render :action => "new"
    else
      flash[:notice] = 'Sub request was successfully created.'
      @users = @sub_request.potential_takers
      for user in @users
       ArMailer.deliver(ArMailer.create_sub_created_notify(user, @sub_request))
      end
      redirect_to :action => "show", :id => @sub_request
    end
  end

  def update
    @sub_request = SubRequest.find(params[:id])
    return unless user_is_owner_or_admin_of(@sub_request.shift, current_department)
    begin
      SubRequest.transaction do
          @sub_request.requested_users = []
          unless params[:list_of_logins].empty? 
             params[:list_of_logins].split(",").each do |l|
                l = l.split("||")
                if l.length == 2
                  for user in l[0].constantize.find(l[1]).users 
                    @sub_request.requested_users << user
                  end
                end
                @sub_request.requested_users << User.find_by_login(l[0]) if l.length == 1
             end
           end
          parse_date_and_time_output(params[:sub_request])
          @sub_request.update_attributes(params[:sub_request])
          @sub_request.save!
        end
      rescue Exception => e
        render :action => "edit", :id => @sub_request
      else
        flash[:notice] = 'Sub Request was successfully updated.'
        redirect_to :action => "show", :id => @sub_request       
      end
  end

  def destroy
    @sub_request = SubRequest.find(params[:id])
    return unless user_is_owner_or_admin_of(@sub_request.shift, current_department)
    @sub_request.destroy
    UserSinksUserSource.delete_all("user_sink_type = 'SubRequest' AND user_sink_id = #{params[:id].to_sql}")
    flash[:notice] = "Successfully destroyed sub request."
    redirect_to sub_requests_path
  end

  def get_take_info
    begin
      @sub_request = SubRequest.find(params[:id])
      if !@sub_request.user_is_eligible?(current_user)
         flash.now[:error] = "Access Denied.  You do not have permission to take that sub_request."
       end
    rescue
      flash.now[:error] = "Oops! It seems the Sub Request you tried to take has already been taken (or canceled). Next time, try clicking sooner."
    end
    
    if Time.now > @sub_request.start
      flash[:notice] = 'This sub request has already started.  If you take this sub request, your shift will begin immediately.'
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
        flash[:error] = 'You are not authorized to take this shift.'
      else
        flash[:error] = e.message.gsub("Validation failed: ", "")
      end
      render :action => "get_take_info"
     end
  end


end

