class AppMailer < ActionMailer::Base

  def sub_taken_notification(sub_request, new_shift)
    recipients  sub_request.shift.user.email
    from        "subtaken@app.stc.com"
    subject     "Your sub request has been taken by #{new_shift.user.name}"
    body        :sub_request => sub_request, :new_shift => new_shift
  end

  def payform_item_change_notification(old_payform_item, new_payform_item = nil)
    recipients  User.find(old_payform_item.user_id).email
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
  
  # beginning of payform notification methods 
  def due_payform_reminder(admin_user, user, message)
    subject     'Payform Reminder'
    recipients  "#{user.name} <#{user.email}>"
    from        "#{admin_user.name} <#{admin_user.email}>"
    reply_to    "#{admin_user.name} <#{admin_user.email}>"
    sent_on     Time.now    
    body        :user => user, :message => message
  end

  def late_payform_warning(admin_user, user, message)
    subject     'Late Payforms Warning'
    recipients  "#{user.name} <#{user.email}>"
    from        "#{admin_user.name} <#{admin_user.email}>"
    reply_to    "#{admin_user.name} <#{admin_user.email}>"
    sent_on     Time.now    
    body        :user => user, :message => message
  end
  
  def printed_payforms_notification(admin_user, message, attachment_name)
    subject       'Printed Payforms ' + Date.today.strftime('%m/%d/%y')
    recipients    "#{admin_user.email}"
    from          'ST Payform Apps <studtech-st-dev-payform@mailman.yale.edu>'
    reply_to      'adam.bray@yale.edu'
    sent_on       Time.now
    content_type  'text/plain'    
    body        :message => message            
    attachment  :content_type => "application/pdf",
                :body         => File.read("data/payforms/" + attachment_name),
                :filename     => attachment_name
  end
  
  def admin_edit_notification(payform, payform_item, edit_item)
  # admin is anybody other than the owner of the payform
    user = payform.user    
    subject       'Your payform has been edited'
    recipients    "#{user.name} <#{user.email}>"
    from          'ST Payform Dev Team <studtech-st-dev-payform@mailman.yale.edu>'
    cc            User.find_by_login(edit_item.edited_by).email
    sent_on       Time.now
    content_type  'text/plain'    
    body          :payform => payform, :payform_item => payform_item, :edit_item => edit_item
  end
  # end of payform notification methods
  
end
