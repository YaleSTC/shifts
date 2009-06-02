# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

  def department_chooser
    if current_user
      if current_user.departments.count == 1
        current_user.departments[0].name
      else
        #TODO: implement multiple department (chooser list)
        #only need to pass params[:department_id] to application controller
        form_tag(url_options, {:id => 'department_chooser'} ) do
          select_tag 'dept', options_for_select(current_user.departments, session[:department_id]), {:onchange =>"$('form_chooser').submit()"}
          submit_tag value = "Switch", :id => 'submit_deptchooser'
          #hide the submit tag if javascript is enabled
          '<script type=\'text/javascript\' charset=\'utf-8\'>
            document.observe(\'dom:loaded\',function(){ $(\'submit_deptchooser\').hide(); });
          </script>'
        end
      end
    end
  end

end

