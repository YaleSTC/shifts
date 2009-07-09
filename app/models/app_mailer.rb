class AppMailer < ActionMailer::Base
  self.delivery_method = :smtp

  def sub_taken_notification(sub_request, new_shift)
    recipients  sub_request.shift.user.email
    from        "subtaken@app.stc.com"
    subject     "Your sub request has been taken by #{new_shift.user.name}"
    body        :sub_request => sub_request, :new_shift => new_shift
  end

  def payform_item_change_notification(old_payform_item, new_payform_item = nil)
    recipients  old_payform_item.user.email
    from        "payformitemchanged@app.stc.com"
    if new_payform_item == nil && !old_payform_item.active
      subject   "Your payform item has been deleted by #{old_payform_item.source}"
    else
      subject   "Your payform item has been modified by #{new_payform_item.source}"
    end
    body        :old_payform_item => old_payform_item, :new_payform_item => new_payform_item
  end

  def password_reset_instructions(user)
    subject       "Password Reset Instructions"
    from          "Yale@yale.edu"
    recipients    user.email
    sent_on       Time.now
    body          :edit_password_reset_url => edit_password_reset_url(user.perishable_token)
  end

  def admin_password_reset_instructions(user)
    subject       "Password Reset Instructions"
    from          "Yale@yale.edu"
    recipients    user.email
    sent_on       Time.now
    body          :edit_admin_password_reset_url => edit_password_reset_url(user.perishable_token)
  end

  def new_user_password_instructions(user)
    subject       "Password Creation Instructions"
    from          "Yale@yale.edu"
    recipients    user.email
    sent_on       Time.now
    body          :edit_new_user_password_url => edit_password_reset_url(user.perishable_token)
  end

  def change_auth_type_password_reset_instructions(user)
    subject       "Password Creation Instructions"
    from          "Yale@yale.edu"
    recipients    user.email
    sent_on       Time.now
    body          :edit_password_url => edit_password_reset_url(user.perishable_token)
  end
  
end
