module UsersHelper

  def deactivate_link(user = @user)
    if user.is_active?(current_department)
      link_to "Deactivate", user_path(user), :method => :delete
    else
      link_to "Restore", {:action => :restore, :id => user}, :method => :post
    end
  end

  def determine_class(user)
    if u = User.find_by_login(user.login)
      if u.departments.include?(@department)
        "stop"
      else
        "caution"
      end
    else
      "notspecial"
    end
  end

  def should_be_checked(user)
    if User.find_by_login(user.login) && User.find_by_login(user.login).departments.include?(@department)
      false
    else
      true
    end
  end
end
