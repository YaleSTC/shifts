class UserMailer < ActionMailer::Base
  default :from => "noreply@shifts.app"

  def registration_confirmation(user)
    mail(:to => user.email, :subject => "Registered")
  end

  def shift_report(shift, report, dept) #Need to test this
    #If a profile field for queue exists, include it in subject
    if queue_field = UserProfileField.where(name: "Queue").first
      user = shift.user
      profile_entry = UserProfileEntry.where(
                                  :user_profile_id => user.user_profile.id,
                                  :user_profile_field_id => queue_field.id).first
      user_queue = profile_entry.content if profile_entry
      queue_text = user_queue ? "(User Queue: #{user_queue})" : ""
    end

    @shift = shift
    @report = report
    mail( to:       shift.user.email,
          from:     shift.user.email,
          cc:       shift.location.try(:report_email),
          subject:  "Shift Report: #{shift.short_display} #{queue_text}",
          date:     Time.now)
  end

 def sub_taken_notification(sub_request, new_shift, dept)
    @sub_request = sub_request
    @new_shift = new_shift
    @dept = dept
    mail( to:       sub_request.shift.user.email,
          from:     dept.department_config.mailer_address,
          subject:  "[Sub Request] #{new_shift.user.name} took your sub!",
          cc:       new_shift.user.email,
          date:     Time.now)
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