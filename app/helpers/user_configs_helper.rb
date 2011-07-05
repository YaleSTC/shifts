module UserConfigsHelper

def reset_payform_pref
  @current_department = Department.find_by_id(session[:department_id])
  @users = User.all
  
 	for user in @users
 		if(Department.find_by_id(user.user_config.default_dept) == @current_department)
 				this_user_config = user.user_config
  	    this_user_config.due_payform_email = true
  	    this_user_config.save
  	end
  	end
end

end
