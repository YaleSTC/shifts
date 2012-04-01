class RestrictionsController < ApplicationController
  before_filter :require_department_admin

  def index
    @restrictions = Restriction.all
  end

  def show
    @restriction = Restriction.find(params[:id])
  end

  def new
    @restriction = Restriction.new
    @restriction.starts ||= Time.now.to_date.to_time
    @restriction.expires ||= Time.now.to_date.to_time
  end

  def create
    parse_date_and_time_output(params[:restriction])
    join_date_and_time(params[:restriction])

    #rename start => starts, end=> expires
    params[:restriction][:starts] = params[:restriction][:start]
    params[:restriction].delete :start
    params[:restriction][:expires] = params[:restriction][:end]
    params[:restriction].delete :end

    @restriction = Restriction.new(params[:restriction])
    begin
      Restriction.transaction do
        @restriction.save(false) #polymorphic associations require a saved database record
        set_sources #setting polymorphic user and location sources
        @restriction.save! #saving again to run validations
      end
    rescue Exception
      render :action => "new"
    else
      flash[:notice] = "Successfully created restriction."
      redirect_to restrictions_path
    end
  end

  def edit
    @restriction = Restriction.find(params[:id])
  end

  def update
    @restriction = Restriction.find(params[:id])
    parse_date_and_time_output(params[:restriction])
    join_date_and_time(params[:restriction])
    if @restriction.update_attributes(params[:restriction])
      flash[:notice] = "Successfully updated restriction."
      redirect_to @restriction
    else
      render :action => 'edit'
    end
  end

  def destroy
    @restriction = Restriction.find(params[:id])
    @restriction.destroy
    flash[:notice] = "Successfully destroyed restriction."
    redirect_to restrictions_url
  end

  protected

  def set_sources
    if params[:for_users]
      params[:for_users].split(",").each do |l|
        if l == l.split("||").first #This is for if javascript is disabled
          l = l.strip
          user_source = User.search(l) || Role.find_by_name(l)
          find_dept = Department.find_by_name(l)
          user_source = find_dept if find_dept && current_user.is_admin_of?(find_dept)
          @restriction.user_sources << user_source if user_source
        else
          l = l.split("||")
          @restriction.user_sources << l[0].constantize.find(l[1]) if l.length == 2 #javascript or not javascript
        end
      end
    end
    if params[:department_wide_locations] && current_user.is_admin_of?(current_department)
      @restriction.location_sources << current_department
      @restriction.loc_groups << current_department.loc_groups
      @restriction.locations << current_department.locations
    elsif params[:for_location_groups]
      params[:for_location_groups].each do |loc_group|
        lg = LocGroup.find(loc_group)
        @restriction.loc_groups << lg
        @restriction.locations << lg.locations
      end
    end
    if params[:for_locations]
      params[:for_locations].each do |loc|
        @restriction.locations << Location.find_by_id(loc)
      end
    end
  end

end
