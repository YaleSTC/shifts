class UserMailer < ActionMailer::Base
  default :from => "Yale@yale.edu"
  
  def registration_confirmation(user)
    mail(:to => user.email, :subject => "Registered")

    self.delivery_method = :smtp
  end

  def shift_report(shift, report, dept) #Need to test this
    #If a profile field for queue exists, include it in subject
    if queue_field = UserProfileField.find(:first, :conditions => {:name => "Queue"})
      user = shift.user
      queue_text = ""
      profile_entry = UserProfileEntry.find(:first, :conditions => {
                                  :user_profile_id => user.user_profile.id, 
                                  :user_profile_field_id => queue_field.id} )
      user_queue = profile_entry.content if profile_entry
      queue_text = "(User Queue: #{user_queue})" if user_queue
    end

    recipients  shift.user.email
    unless shift.location.report_email.blank?
      cc        shift.location.report_email
    end
    from        shift.user.email
    subject     "Shift Report: #{shift.short_display} #{queue_text}"
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
    @sub_request = sub_request
    @new_shift = new_shift
    @dept = dept
    mail(:to => sub_request.shift.user.email, :from => dept.department_config.mailer_address, 
    	:subject => "[Sub Request] #{new_shift.user.name} took your sub!", :cc => new_shift.user.email, :date => Time.now)
  end

  def payform_item_modify_notification(new_payform_item, dept)
  	@new_payform_item = new_payform_item
    @dept = dept
  	mail(:to => new_payform_item.user.email, :from => dept.department_config.mailer_address, 
  		:subject => "Your payform has been modified by #{new_payform_item.source}", :date => Time.now)
  end

  def payform_item_deletion_notification(old_payform_item, dept)
    @old_payform_item = old_payform_item
    @dept = dept
    mail(:to => old_payform_item.user.email, :from => dept.department_config.mailer_address, 
    	:subject=> "Your payform item has been deleted by #{old_payform_item.versions.last.user}", :date => Time.now)
  end

  def password_reset_instructions(user)
    @edit_password_reset_url = edit_password_reset_url(user.perishable_token)
    mail(:to => user.email, :subject => "Password Reset Instructions",
    	:date => Time.now)
  end

  def admin_password_reset_instructions(user)
    @edit_admin_password_reset_url = edit_password_reset_url(user.perishable_token)
    mail(:to => user.email, :subject => "Password Reset Instructions",
    	:date => Time.now)
  end

# For use when users are imported from csv #duplicate found in ar_mailer, not DRY -ben
  def new_user_password_instructions(user, dept)
    @edit_new_user_password_url = edit_password_reset_url(user.perishable_token)
    @user = user
    @dept = dept
    mail(:to => user.email, :from => dept.department_config.mailer_address, 
    	:subject => "Password Creation Instructions", :date => Time.now)
  end

  def change_auth_type_password_reset_instructions(user)
    @edit_password_url = edit_password_reset_url(user.perishable_token)
    mail(:to => user.email, :subject => "Password Creation Instructions",
    	:date => Time.now)
  end
end