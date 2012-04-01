 #This line may be unnessecary. See line 6.
ActionMailer::Base.delivery_method = :smtp

class AppMailer < ActionMailer::Base

  self.delivery_method = :smtp

  def shift_report(shift, report, dept)
    recipients  shift.user.email
    unless shift.location.report_email.blank?
      cc        shift.location.report_email
    end
    from        shift.user.email
    subject     "Shift Report: #{shift.short_display}"
    sent_on     Time.now
    body        :shift => shift, :report => report
  end

#  def sub_created_notify(sub)
#    subject     "[Sub Request] Sub needed for " + sub.shift.short_display
#    recipients  "sub.request.mailer@yale.edu"
#    bcc         sub.email_list
#    from        sub.user.email
#    body        :sub => sub
#  end

 def sub_taken_notification(sub_request, new_shift, dept)
    recipients  sub_request.shift.user.email
    cc          new_shift.user.email
    from        dept.department_config.mailer_address
    subject     "[Sub Request] #{new_shift.user.name} took your sub!"
    sent_on     Time.now
    body        :sub_request => sub_request, :new_shift => new_shift
  end

  def payform_item_modify_notification(new_payform_item, dept)
    recipients  new_payform_item.user.email
    from        dept.department_config.mailer_address
    sent_on     Time.now
    subject     "Your payform has been modified by #{new_payform_item.source}"
    body        :new_payform_item => new_payform_item
  end

  def payform_item_deletion_notification(old_payform_item, dept)
    recipients  old_payform_item.user.email
    from        dept.department_config.mailer_address
    sent_on     Time.now
    subject     "Your payform item has been deleted by #{old_payform_item.versions.last.user}"
    body        :old_payform_item => old_payform_item
  end

  def password_reset_instructions(user)
    subject     "Password Reset Instructions"
    from        "Yale@yale.edu"
    recipients  user.email
    sent_on     Time.now
    body        :edit_password_reset_url => edit_password_reset_url(user.perishable_token)
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

