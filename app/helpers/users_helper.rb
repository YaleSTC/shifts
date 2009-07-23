module UsersHelper

  def deactivate_link(user = @user)
    active = user.is_active?(current_department)
    link_to_remote (active ? "Deactivate" : "Restore"), {:url => toggle_user_path(user),
      :success => "$('#user#{user.id}').toggleClass('disabled');$('#user#{user.id} a.toggle_link').text(($('#user#{user.id}').hasClass('disabled') ? 'Restore' : 'Deactivate'))"},
      :href => toggle_user_path(user), :class => 'toggle_link'
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
