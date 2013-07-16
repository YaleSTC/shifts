class UsersController < ApplicationController
  before_filter :require_admin_or_superuser, :except => 'autocomplete'

  def index
    if params[:show_inactive]
      @users = @department.users
    else
      @users = current_department.active_users.sort_by(&:reverse_name)
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

    respond_to do |wants|
      wants.html
      wants.csv { render :text => @users.to_csv_users }
    end
  end

  def show
    @user = User.find(params[:id])
    @user_profile = UserProfile.where(:user_id => params[:id]).first
    unless @user_profile.user.departments.include?(@department)
      flash[:error] = "This user does not have a profile in this department."
    end
    @user_profile_entries = @user_profile.user_profile_entries.select{ |entry| entry.user_profile_field.department_id == @department.id && entry.user_profile_field.public }
  end

  def show_shifts
    @user = User.find(params[:id])
    @shifts = @user.shifts.sort_by{|s| s.start}.reverse
  end

  def ldap_search
    @results=[]
    return @results unless params[:user][:first_name] || params[:user][:last_name] || params[:user][:email]
    @results=User.search_ldap(params[:user][:first_name],params[:user][:last_name],params[:user][:email],5)
  end

  def new
    @user = User.new
    @results = []
  end

  def fill_form
    @user = User.new(params[:user])
  end

  def create
    if @user = User.where(:login => params[:user][:login]).first
      if @user.departments.include? @department #if user is already in this department
        flash[:notice] = "This user already exists in this department."
      else
        @user.roles += (params[:user][:role_ids] ? params[:user][:role_ids].collect{|id| Role.find(id)} : [])
        @user.departments << @department unless @user.departments.include?(@department)
        flash[:notice] = "User successfully added to new department."
      end
      @user.set_payrate(params[:payrate], @department)
      redirect_to @user
    else
      @user = User.new(params[:user])
      @user.auth_type = @appconfig.login_options[0] if @appconfig.login_options.size == 1
      @user.set_random_password
      @user.departments << @department unless @user.departments.include?(@department)
      if @user.save
        UserMailer.registration_confirmation(@user).deliver
        @user.set_payrate(params[:payrate], @department)
        UserProfileField.all.each do |field|
          UserProfileEntry.create!(:user_profile_id => @user.user_profile.id, :user_profile_field_id => field.id)
        end
        if @user.auth_type == 'built-in' #What is going on here?
          @user.deliver_password_reset_instructions!(Proc.new {|n| UserMailer.new_user_password_instructions(n, current_department).deliver})
          flash[:notice] = "Successfully created user and emailed instructions for setting password."
        else
          flash[:notice] = "Successfully created user."
        end
        redirect_to @user
      else
        render :action => 'new'
      end
    end
  end

  def edit
    @user = User.find(params[:id])
    @user_profile = UserProfile.where(:user_id => @user.id).first
    @user_profile_entries = @user.user_profile.user_profile_entries.select{|entry| entry.user_profile_field.department_id == @department.id }
  end

  def update
    #TODO: prevent params hacking w/ regard to setting roles and login and payrate
    params[:user][:role_ids] ||= []
    @user = User.find(params[:id])
    #store role changes, or else they'll overwrite roles in other departments
    #remove all roles associated with this department
    department_roles = @user.roles.select{|role| role.department == current_department}
    updated_roles = @user.roles - department_roles
    #now add back all checked roles associated with this department (or empty if none were checked)
    updated_roles += (params[:user][:role_ids] ? params[:user][:role_ids].collect{|id| Role.find(id)} : [])
    #We can't save the roles association via update attributes, so we have to do it manually
    @user.roles = updated_roles
    @user.save!
    #Finally to prevent the @user.update_attribues from attempting to update the roles, we must remove them from params
    params[:user].delete(:role_ids)
    
    #So that the User Profile can be updated as well
      @user_profile = UserProfile.where(:user_id => User.find(params[:id]).id).first
      @user_profile_entries = params[:user_profile_entries]

      if @user_profile_entries
        @user_profile_entries.each do |entry_id, entry_content|
          entry = UserProfileEntry.find(entry_id)
          @content = ""
            if entry.display_type == "check_box"
              UserProfileEntry.find(entry_id).values.split(", ").each do |value|
                c = entry_content[value]
                @content += value + ", " if c == "1"
              end
              @content.gsub!(/, \Z/, "")
              entry.content = @content
              entry.save
            elsif entry.display_type == "radio_button"
              entry.content = entry_content["1"]
              entry.save
            else
              entry.content = entry_content[entry_id]
              entry.save
            end
          end
      end

    @user_profile = UserProfile.where(:user_id => @user.id).first
    @user_profile_entries = @user_profile.user_profile_entries.select{|entry| entry.user_profile_field.department_id == @department.id }
    @user.set_random_password if params[:reset_password]
    @user.deliver_password_reset_instructions!(Proc.new {|n| UserMailer.change_auth_type_password_reset_instructions(n).deliver}) if @user.auth_type=='CAS' && params[:user][:auth_type]=='built-in'
    
    
    
    if @user.update_attributes(params[:user])
      @user.set_payrate(params[:payrate].gsub(/\$/,""), @department) if params[:payrate]
      flash[:notice] = "Successfully updated user."
      @user.deliver_password_reset_instructions!(Proc.new {|n| UserMailer.admin_password_reset_instructions(n).deliver}) if params[:reset_password]
      redirect_to @user
    else
      render :action => 'edit'
    end
  end

  def destroy #the preferred action. really only disables the user for that department.
  # DRAFT IMPROVEMENT -ben
  #    @user = User.find(params[:id])
  #    @user.destroy
  #    flash[:notice] = "Successfully destroyed user."
  #    redirect_to department_users_path(current_department)
  # END DRAFT
    @user = User.find(params[:id])
    if @user.toggle_active(@department) #new_entry.save
      flash[:notice] = "Successfully deactivated user."
      redirect_to @user
    else
      render :action => 'edit'
    end
  end

  # I believe that neither of these two actions is in use anymore -ben
  # Replacement for destroy action
  #  def deactivate
  #    @user = User.find(params[:id])
  #    if @user.toggle_active(@department) #new_entry.save
  #      flash[:notice] = "Successfully deactivated user."
  #      redirect_to @user
  #    else
  #      render :action => 'edit'
  #    end
  #  end

  # Reactivates the user
  #  def restore
  #    @user = User.find(params[:id])
  #    new_entry = DepartmentsUser.new();
  #    old_entry = DepartmentsUser.find(:first, :conditions => { :user_id => @user, :department_id => @department})
  #    new_entry.attributes = old_entry.attributes
  #    new_entry.active = true
  #    DepartmentsUser.delete_all( :user_id => @user, :department_id => @department )
  #    if new_entry.save
  #      flash[:notice] = "Successfully restored user."
  #      redirect_to @user
  #    else
  #      render :action => 'edit'
  #    end
  #  end

  # To be replaced with destroy
  def really_destroy #if we ever need an action that actually destroys users.
    @user = User.find(params[:id])
    @user.destroy
    flash[:notice] = "Successfully destroyed user."
    redirect_to department_users_path(current_department)
  end

  # Empty action, necessary for a view -ben
  # Used for importing from CSV
  def import
  end

  # Used for importing from CSV
  def verify_import
    file = params[:file]
    flash[:notice]="The users in red already exist in this department and should not be imported. The users in yellow exist in other departments. They can be imported, but we figured you should know."
    begin
      @users = User.import(file)
      @no_nav = true
    rescue Exception => e
      flash[:notice] = "The file you uploaded is invalid. Please make sure the file you upload is a csv file and the columns are in the right order."
      render :action => 'import'
    end
  end

  # Used for importing from CSV
  def save_import
    if params[:commit]=="Cancel"
      redirect_to import_department_users_path(@department) and return
    end
    @users=params[:users_to_import].collect{|i| params[:user][i]}
    failures = []
    @users.each do |u|
      if @user = User.where(:login => u[:login]).first
        if @user.departments.include? @department #if user is already in this department
          #don't modify any data, as this is probably a mistake
          failures << {:user=>u, :reason => "User already exists in this department!"}
        else
          @user.role = u[:role]
          #add user to new department
          @user.departments << @department unless @user.departments.include?(@department)
          @user.save
        end
      else
        @user = User.new(u)
        @user.auth_type = @appconfig.login_options[0] if @appconfig.login_options.size == 1
        @user.set_random_password
        @user.departments << @department unless @user.departments.include?(@department)
        if @user.save
          @user.deliver_password_reset_instructions!(Proc.new {|n| ArMailer.deliver_new_user_password_instructions(n, current_department)}) if @user.auth_type=='built-in'
        else
          failures << {:user=>u, :reason => "Check all fields to make sure they\'re ok"}
        end
      end
    end
    if failures.empty?
      flash[:notice] = "All users successfully added."
      redirect_to department_users_path(@department)
    else
      @users=failures.collect{|e| User.new(e[:user])}
      flash[:notice] = "The users below failed for the following reasons:<br />"
      failures.each{|e| flash[:notice]+="#{e[:user][:login]}: #{e[:reason]}<br />"}
      render :action=> 'verify_import'
    end
  end

  def autocomplete
    @list = []
    
    classes = params[:classes]
    
    if classes.include?("User")
      users = Department.find(params[:department_id]).users.sort_by(&:first_name)
      users.each do |user|
        if user.login.downcase.include?(params[:q]) or user.name.downcase.include?(params[:q])
        #if (user.login and user.login.include?(params[:q])) or (user.name and user.name.include?(params[:q]))
          @list << {:id => "User||#{user.id}", :name => "#{user.name} (#{user.login})"}
        end
      end
    end
    if classes.include?("Department")
      departments = current_user.departments.sort_by(&:name)
      departments.each do |department|
        if department.name.downcase.include?(params[:q])
          #if (user.login and user.login.include?(params[:q])) or (user.name and user.name.include?(params[:q]))
         # department.users.each do |user|
          #  @list << {:id => "User||#{user.id}", :name => "#{user.name} (#{user.login})"}  
          #end
          @list << {:id => "Department||#{department.id}", :name => "Department: #{department.name}"}
        end
      end
    end
    if classes.include?("Role")
      roles = Department.find(params[:department_id]).roles.sort_by(&:name)
      roles.each do |role|
        if role.name.downcase.include?(params[:q])
          #if (user.login and user.login.include?(params[:q])) or (user.name and user.name.include?(params[:q]))
          #role.users.each do |u|
          #  @list << {:id => "User||#{u.id}", :name => "#{u.name} (#{u.login})"}  
          #end
          @list << {:id => "Role||#{role.id}", :name => "Role: #{role.name}"}
        end
      end
    end

    #@users = @users.collect{|user| :id => user.id, :name => user.name}
    render :layout => false
  end

  def search
    @users = current_department.active_users

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

  def toggle #for ajax deactivation/restore
    @user = User.find(params[:id])
    @user.toggle_active(@department)
    respond_to do |format|
      format.html {redirect_to user_path(@user)}
      format.js {render :nothing => true}
    end
  end

  private

  def switch_department_path
    department_users_path(current_department)
  end

  def require_admin_or_superuser
    redirect_to(access_denied_path) unless current_user.is_admin_of?(current_department) || current_user.is_superuser?
  end
end
