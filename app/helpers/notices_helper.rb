module NoticesHelper
  def current_shift_check
    if current_user.current_shift
      current_user.current_shift.location == location
    else
      false
    end
  end
end

