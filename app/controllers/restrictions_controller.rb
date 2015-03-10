class RestrictionsController < ApplicationController
  layout 'shifts'

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
        @restriction.save(validate: false) 
        set_sources #setting polymorphic user and location sources
        @restriction.save! #saving again to run validations
      end
    rescue Exception
      render action: "new"
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
      render action: 'edit'
    end
  end

  def destroy
    @restriction = Restriction.find(params[:id])
    @restriction.destroy
    flash[:notice] = "Successfully destroyed restriction."
    redirect_to restrictions_url
  end

  protected
  # Can't do this until we decide what to do with restrictions
  def set_sources
    if params[:for_users]
      @restriction.users = parse_users_autocomplete(params[:for_users])
    end
    if params[:department_wide_locations] && current_user.is_admin_of?(current_department)
      # Do we allow department wide actions? -Hugh
      # @restriction.location_sources << current_department
      @restriction.loc_groups = current_department.loc_groups
      @restriction.locations = current_department.locations
    elsif params[:for_location_groups]
      params[:for_location_groups].each do |loc_group|
        lg = LocGroup.find(loc_group)
        @restriction.loc_groups << lg
        @restriction.locations += lg.locations
      end
    elsif params[:for_locations]
      params[:for_locations].each do |loc|
        @restriction.locations << Location.find_by_id(loc)
      end
    end
  end
end
