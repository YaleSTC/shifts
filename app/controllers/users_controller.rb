class UsersController < ApplicationController
  #TODO: add authorization before_filter here and update the action code accordingly
  # a superuser can view all users while a department admin can manage a department's users
  # depending on the dept chooser
  def index
    if params[:show_inactive]
      @users = @department.users
  else
      @users = @department.users.select{|user| user.is_active?(@department)}
    end

    if params[:search]
      params[:search] = params[:search].downcase
      @search_result = []
      @users.each do |user|
        if user.login.downcase.include?(params[:search]) or user.name.downcase.include?(params[:search])
          @search_result << user
        end
      end
      @users = @search_result
    end

    @users = @users.sort_by(&:last_name)
  end

  def show
    @user = User.find(params[:id])
  end

  def ldap_search
    @results=User.search_ldap(params[:user][:first_name],params[:user][:last_name],params[:user][:email],params[:user][:login],5)
  end

  def new
    @user = User.new
#    if params[:ldap_search]
#      @results=User.search_ldap(params[:user][:first_name],params[:user][:last_name])
#    else
      @results = []
#    end
  end

  def create
    @user = User.new(params[:user])
    @user.auth_type = $appconfig.login_options[0] if $appconfig.login_options.size == 1
    if @user.auth_type == "authlogic"
      @user.password = @user.password_confirmation = random_password
      @user.departments << @department
      if @user.save
        @user.deliver_password_reset_instructions!(Proc.new {|n| AppMailer.deliver_new_user_password_instructions(n)})
        flash[:notice] = "Successfully created user and emailed instructions for setting password."
        redirect_to @user
      else
        render :action => 'new'
      end
    else
      if @user = User.find_by_login(params[:user][:login])
        if @user.departments.include? @department #if user is already in this department
          #don't modify any data, as this is probably a mistake
          flash[:notice] = "This user already exists in this department!"
          redirect_to @user
        else
          #make sure not to lose roles in other departments
          #remove all roles associated with this department
          department_roles = @user.roles.select{|role| role.departments.include? @department}
          @user.roles -= department_roles
          #now add back all checked roles associated with this department
          @user.roles |= (params[:user][:role_ids] ? params[:user][:role_ids].collect{|id| Role.find(id)} : [])

          #add user to new department
          @user.departments << @department
          flash[:notice] = "User successfully added to new department."
          redirect_to @user
        end
      else #user is a new user
        #create from LDAP if possible; otherwise just use the given information
        @user = User.import_from_ldap(params[:user][:login], @department) || User.create(params[:user])

        #if a name was given, it should override the name from LDAP
        @user.first_name = (params[:user][:first_name]) unless params[:user][:first_name]==""
        @user.last_name = (params[:user][:last_name]) unless params[:user][:last_name]==""
        @user.roles = (params[:user][:role_ids] ? params[:user][:role_ids].collect{|id| Role.find(id)} : [])
        @user.password = @user.password_confirmation = random_password
        @user.auth_type='CAS'
        if @user.save
          flash[:notice] = "Successfully created user."
          redirect_to @user
        else
           render :action => 'new'
        end
      end
#         y @user #debug output
    end
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    #TODO: prevent params hacking w/ regard to setting roles and login
    params[:user][:role_ids] ||= []
    @user = User.find(params[:id])

    #store role changes, or else they'll overwrite roles in other departments
    #remove all roles associated with this department
    department_roles = @user.roles.select{|role| role.departments.include? @department}
    updated_roles = @user.roles - department_roles
    #now add back all checked roles associated with this department
    updated_roles |= (params[:user][:role_ids] ? params[:user][:role_ids].collect{|id| Role.find(id)} : [])
    params[:user][:role_ids] = updated_roles
    @user.password=@user.password_confirmation=random_password if params[:reset_password]
    @user.deliver_password_reset_instructions!(Proc.new {|n| AppMailer.deliver_change_auth_type_password_reset_instructions(n)}) if @user.auth_type=='CAS' && params[:user][:auth_type]=='authlogic'
    if @user.update_attributes(params[:user])
      flash[:notice] = "Successfully updated user."
      @user.deliver_password_reset_instructions!(Proc.new {|n| AppMailer.deliver_admin_password_reset_instructions(n)}) if params[:reset_password]
      redirect_to @user
    else
      render :action => 'edit'
    end
  end

  def destroy #the preferred action. really only disables the user for that department.
    @user = User.find(params[:id])
    new_entry = DepartmentsUser.new();
    old_entry = DepartmentsUser.find(:first, :conditions => { :user_id => @user, :department_id => @department})
    new_entry.attributes = old_entry.attributes
    new_entry.active = false
    DepartmentsUser.delete_all( :user_id => @user, :department_id => @department )
    if new_entry.save
      flash[:notice] = "Successfully deactivated user."
      redirect_to @user
    else
      render :action => 'edit'
    end
  end

  def restore #reactivates the user
    @user = User.find(params[:id])
    new_entry = DepartmentsUser.new();
    old_entry = DepartmentsUser.find(:first, :conditions => { :user_id => @user, :department_id => @department})
    new_entry.attributes = old_entry.attributes
    new_entry.active = true
    DepartmentsUser.delete_all( :user_id => @user, :department_id => @department )

    if new_entry.save
      flash[:notice] = "Successfully restored user."
      redirect_to @user
    else
      render :action => 'edit'
    end
  end

  def really_destroy #if we ever need an action that actually destroys users.
    @user = User.find(params[:id])
    @user.destroy
    flash[:notice] = "Successfully destroyed user."
    redirect_to department_users_path(current_department)
  end

  def mass_add
    #just a view
  end

  def mass_create
    errors = User.mass_add(params[:logins], @department)
    unless errors.empty?
      flash[:error] = "Import of the following users failed:<br /> "+(errors.join "<br />")
    end
    redirect_to department_users_path
  end

  def autocomplete
    departments = current_user.departments.sort_by(&:name)
    users = Department.find(params[:department_id]).users.sort_by(&:first_name)
    roles = Department.find(params[:department_id]).roles.sort_by(&:name)

    @list = []
    users.each do |user|
      if user.login.downcase.include?(params[:q]) or user.name.downcase.include?(params[:q])
      #if (user.login and user.login.include?(params[:q])) or (user.name and user.name.include?(params[:q]))
        @list << {:id => "User||#{user.id}", :name => "#{user.name} (#{user.login})"}
      end
    end
    departments.each do |department|
      if department.name.downcase.include?(params[:q])
        #if (user.login and user.login.include?(params[:q])) or (user.name and user.name.include?(params[:q]))
        @list << {:id => "Department||#{department.id}", :name => "Department: #{department.name}"}
      end
    end
    roles.each do |role|
      if role.name.downcase.include?(params[:q])
        #if (user.login and user.login.include?(params[:q])) or (user.name and user.name.include?(params[:q]))
        @list << {:id => "Role||#{role.id}", :name => "Role: #{role.name}"}
      end
    end

    #@users = @users.collect{|user| :id => user.id, :name => user.name}
    render :layout => false
  end

  def search
    @users = @department.users

    #filter results if we are searching
    if params[:search]
      params[:search] = params[:search].downcase
      @search_result = []
      @users.each do |user|
        if user.login.downcase.include?(params[:search]) or user.name.downcase.include?(params[:search])
          @search_result << user
        end
      end
      @users = @search_result.sort_by(&:last_name)
    end
  end

  private

  def switch_department_path
    department_users_path(current_department)
  end
end
