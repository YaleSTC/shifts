class AppMailer < ActionMailer::Base
  default_url_options[:host] = request.host


  def sub_taken_notification(sub_request, new_shift, dept)
    recipients  sub_request.shift.user.email
    from        dept.department_config.mailer_address
    subject     "Your sub request has been taken by #{new_shift.user.name}"
    sent_on     Time.now
    body        :sub_request => sub_request, :new_shift => new_shift
  end

  def payform_item_change_notification(old_payform_item, new_payform_item)
    recipients  new_payform_item.user.email
    from        "payformitemchanged@app.stc.com"
    sent_on     Time.now
    subject     "Your payform item has been modified by #{new_payform_item.source}"
    body        :old_payform_item => old_payform_item, :new_payform_item => new_payform_item
  end

  def payform_item_deletion_notification(old_payform_item)
    recipients  old_payform_item.user.email
    from        "payformitemchanged@app.stc.com"
    sent_on     Time.now
    subject   "Your payform item has been deleted by #{old_payform_item.source}"
    body        :old_payform_item => old_payform_item
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

# For use when users are imported from csv #duplicate found in ar_mailer, not DRY -ben
  def new_user_password_instructions(user, dept)
    subject       "Password Creation Instructions"
    from          dept.department_config.mailer_address
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
