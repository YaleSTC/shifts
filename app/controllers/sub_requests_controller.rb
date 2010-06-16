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
    return unless user_is_owner_or_admin_of(@sub_request.shift, current_department)
  end

  def edit
    @sub_request = SubRequest.find(params[:id])
    return unless user_is_owner_or_admin_of(@sub_request.shift, current_department)
  end

  def create

    this_shift = Shift.find(params[:shift_id])
    params[:sub_request] = parse_simple_time_select_output(params[:sub_request], "mandatory_start", this_shift.start)
    params[:sub_request] = parse_simple_time_select_output(params[:sub_request], "mandatory_end", this_shift.end)
    params[:sub_request] = parse_simple_time_select_output(params[:sub_request], "start", this_shift.start)
    params[:sub_request] = parse_simple_time_select_output(params[:sub_request], "end", this_shift.end)

    @sub_request = SubRequest.new(params[:sub_request])
    @sub_request.shift = this_shift   ##or this could say Shift.find(params[:shift_id])
    @sub_request.user = @sub_request.shift.user


 ###################################################################################################
    begin
      SubRequest.transaction do
        @sub_request.save(false)
       if params[:list_of_logins].empty?
         @sub_request.user_sources << current_department
       else
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
    return unless user_is_owner_or_admin_of(@sub_request.shift, current_department)
    UserSinksUserSource.delete_all("user_sink_type= 'SubRequest' AND user_sink_id = #{@sub_request.id.to_sql}")
    params[:list_of_logins].split(",").each do |l|
      l = l.split("||")
      @sub_request.user_sources << l[0].constantize.find(l[1]) if l.length == 2
      @sub_request.user_sources << User.find_by_login(l[0]) if l.length == 1
    end

    this_shift = @sub_request.shift
    params[:sub_request] = parse_simple_time_select_output(params[:sub_request], "mandatory_start", this_shift.start)
    params[:sub_request] = parse_simple_time_select_output(params[:sub_request], "mandatory_end", this_shift.end)
    params[:sub_request] = parse_simple_time_select_output(params[:sub_request], "start", this_shift.start)
    params[:sub_request] = parse_simple_time_select_output(params[:sub_request], "end", this_shift.end)

    if @sub_request.update_attributes(params[:sub_request])
      flash[:notice] = 'SubRequest was successfully updated.'
      redirect_to @sub_request
    else
      render :action => "edit"
    end
  end

  def destroy
    @sub_request = SubRequest.find(params[:id])
    return unless user_is_owner_or_admin_of(@sub_request.shift, current_department)
    @sub_request.destroy
    UserSinksUserSource.delete_all("user_sink_type = 'SubRequest' AND user_sink_id = #{params[:id].to_sql}")
    flash[:notice] = "Successfully destroyed sub request."
    redirect_to dashboard_url
  end

  def get_take_info
    begin
      @sub_request = SubRequest.find(params[:id])
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


  def parse_simple_time_select_output(form_output, field_name, original_shift)
    form_output[field_name.intern] = Time.parse( form_output[:"#{field_name}(5i)"] )
    form_output.delete(:"#{field_name}(5i)")
	return form_output
  end



### sample function from simple_time_select author
### This is the way to go - I think I understand what it's doing now ~Casey

#  def fix_show_attrs(show_attrs)
#    %w{show_time load_in doors}.each do |time_type|
#      date_type = ( time_type == 'show_time' ) ? 'show_date' : "#{time_type}_date"

#      if show_attrs["#{time_type}(5i)"].blank?
#        show_attrs.delete "#{time_type}"
#      else
#        show_date = [ show_attrs["#{date_type}(1i)"], show_attrs["#{date_type}(2i)"], show_attrs["#{date_type}(3i)"] ].join('-')
#        show_attrs["#{time_type}"] = Time.parse "#{show_date} "+ show_attrs["#{time_type}(5i)"]
#      end
#      show_attrs.delete("#{date_type}(1i)")
#      show_attrs.delete("#{date_type}(2i)")
#      show_attrs.delete("#{date_type}(3i)")
#      show_attrs.delete("#{time_type}(5i)")
#    end
#    show_attrs
#  end




end

