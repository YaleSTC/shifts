module UsersHelper

  def deactivate_link(user = @user)
    if user.is_active?(current_department)
      link_to "Deactivate", user_path(user), :method => :delete
    else
      link_to "Restore", {:action => :restore, :id => user}, :method => :post
    end
  end

end

