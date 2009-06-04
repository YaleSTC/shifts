class UsersController < ApplicationController
  def index
    # if params[:deactivated]
      @users = @department.users
    # else
      # @users = @department.users.select{|user| user.is_active?(@department)}
    # end
  end

  def show
    @user = User.find(params[:id])
  end

  def new
    @user = User.new
  end

  def create  
    #if user already in database
    if @user = User.find_by_netid(params[:user][:netid])      
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
      @user = User.import_from_ldap(params[:user][:netid], @department) || User.create(params[:user])
    
      #if a name was given, it should override the name from LDAP
      @user.name = params[:user][:name] unless params[:user][:name] == ""
      @user.roles = (params[:user][:role_ids] ? params[:user][:role_ids].collect{|id| Role.find(id)} : [])
      if @user.save
        flash[:notice] = "Successfully created user."
        redirect_to @user
      else
        render :action => 'new'
      end
    end
    # y @user #debug output
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    params[:user][:role_ids] ||= []
    @user = User.find(params[:id])
  
    #store role changes, or else they'll overwrite roles in other departments
    #remove all roles associated with this department
    department_roles = @user.roles.select{|role| role.departments.include? @department}
    updated_roles = @user.roles - department_roles
    #now add back all checked roles associated with this department
    updated_roles |= (params[:user][:role_ids] ? params[:user][:role_ids].collect{|id| Role.find(id)} : [])
    params[:user][:role_ids] = updated_roles
    
    if @user.update_attributes(params[:user])
      flash[:notice] = "Successfully updated user."
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
    new_entry.deactivated = true
    DepartmentsUser.delete_all( :user_id => @user, :department_id => @department )
    if new_entry.save
      flash[:notice] = "Successfully deactivated user."
      redirect_to @user
    else
      render :action => 'edit'
    end
  end

  def restore #activates the user
    #TODO: modify the code from destroy and get this working
    @user = User.find(params[:id])
    dept_user = DepartmentsUser.find(:first, :conditions => { :user_id => @user, :department_id => @department})
    dept_user.deactivated = false
    if dept_user.save
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
    errors = User.mass_add(params[:netids], @department)
    unless errors.empty?
      flash[:error] = "Import of the following users failed:<br /> "+(errors.join "<br />")
    end
    redirect_to department_users_path
  end
end

