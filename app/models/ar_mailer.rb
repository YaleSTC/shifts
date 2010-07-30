require 'action_mailer/ar_mailer'

ActionMailer::Base.delivery_method = :activerecord
class ArMailer < ActionMailer::ARMailer
  self.delivery_method = :activerecord
# For use when users are imported from csv
  def new_user_password_instructions(user, dept)
    subject       "Password Creation Instructions"
    from          AppConfig.first.mailer_address
    recipients    user.email
    sent_on       Time.now
    body          :edit_new_user_password_url => edit_password_reset_url(user.perishable_token)
  end

# Beginning of payform notification methods
  def due_payform_reminder(user, message, dept)
    subject     'Due Payform Reminder'
    recipients  "#{user.name} <#{user.email}>"
    from        "#{dept.department_config.mailer_address}"
    sent_on     Time.now
    body        :user => user, :message => message
  end

  def late_payform_warning(user, message, dept)
    subject     'Late Payforms Warning'
    recipients  "#{user.name} <#{user.email}>"
    from        "#{dept.department_config.mailer_address}"
    sent_on     Time.now
    body        :user => user, :message => message
  end

#this code is currently not used anywhere in the code so Adam told me to comment it out for now. - Maria
  # def printed_payforms_notification(admin_user, message, attachment_name)
  #   subject       'Printed Payforms ' + Date.today.strftime('%m/%d/%y')
  #   recipients    "#{admin_user.email}"
  #   from          "#{dept.department_config.mailer_address}"
  #   sent_on       Time.now
  #   content_type  'text/plain'
  #   body        :message => message
  #   attachment  :content_type => "application/pdf",
  #               :body         => File.read("data/payforms/" + attachment_name),
  #               :filename     => attachment_name
  # end

# Notifies a user when somebody else edits their payform
  def admin_edit_notification(payform, payform_item, edit_item, dept)
    user = payform.user
    subject       'Your payform has been edited'
    recipients    "#{user.name} <#{user.email}>"
    from          dept.department_config.mailer_address
    cc            User.find_by_login(edit_item.edited_by).email
    sent_on       Time.now
    content_type  'text/plain'
    body          :payform => payform, :payform_item => payform_item, :edit_item => edit_item
  end

  # SUB REQUEST:
  # email the specified list or default list of eligible takers
  def sub_created_notify(user, sub)
    subject     "[Sub Request] Sub needed for " + sub.shift.short_display
    recipients  "#{user.name} <#{user.email}>"
    from        sub.user.email
    sent_on     Time.now
    body        :sub => sub
  end

  #email a group of users who want to see whenever a sub request is taken
  def sub_taken_watch(user, sub_request, new_shift, dept) 
    subject     "Re: [Sub Request] Sub needed for " + sub_request.shift.short_display 
    recipients  "#{user.name} <#{user.email}>"
    from        sub_request.shift.user.email
    sent_on     Time.now
    body        :sub_request => sub_request, :new_shift => new_shift  
  end


  #email the user who took the sub and the requester of the sub that their shift has been taken
  def sub_taken_notification(sub_request, new_shift, dept)
    subject     "[Sub Request] #{new_shift.user.name} took your sub!"
    recipients  sub_request.shift.user.email
    cc          new_shift.user.email
    from        dept.department_config.mailer_address
    sent_on     Time.now
    body        :sub_request => sub_request, :new_shift => new_shift
  end

  #EMAILING STATS
  #email notifies admin that a shift has been missed, was signed into late, or was left early
  def email_stats (missed_shifts, late_shifts, left_early_shifts, dept)
    subject      "Shift Statistics for #{dept.name}:" + (Time.now - 86400).strftime('%m/%d/%y') #this assumes that the email is sent the day after the shifts (ex. after midnight) so that the email captures all of the shifts
    recipients   dept.department_config.stats_mailer_address  
    from         dept.department_config.mailer_address
    sent_on      Time.now
    body         :missed_shifts => missed_shifts, :late_shifts => late_shifts, :left_early_shifts => left_early_shifts
  end


  #STALE SHIFTS
  #an email is sent to a student if they have been inactive in their shift for an hour
  def stale_shift(user, stale_shift, dept) 
    subject       "Your Shift in the #{stale_shift.location.name} has been inactive for an hour."
    recipients    "#{user.name} <#{user.email}>"
    from          dept.department_config.mailer_address
    sent_on       Time.now
    body          :user => user, :stale_shift => stale_shift
  end


end

