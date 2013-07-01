module UsersHelper

  def deactivate_link(user = @user)
    active = user.is_active?(current_department)
    link_to (active ? "Deactivate" : "Restore"), {:url => toggle_user_path(user),
      :success => "$('#user#{user.id}').toggleClass('disabled');$('#user#{user.id} a.toggle_link').text(($('#user#{user.id}').hasClass('disabled') ? 'Restore' : 'Deactivate'))"},
      :href => toggle_user_path(user), :remote => true, :class => 'toggle_link'
  end

  def determine_class(user)
    if u = User.find_by_login(user.login)
      if u.departments.include?(current_department)
        "stop"
      else
        "caution"
      end
    else
      "notspecial"
    end
  end

  def determine_auth_type(user,l)
    if u = User.find_by_login(user.login)
      if u.auth_type == l
        true
      else
        false
      end
    else
      if l == "CAS"
        true
      else
        false
      end
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
