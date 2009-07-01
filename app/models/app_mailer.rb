class AppMailer < ActionMailer::Base
  default_url_options[:host] = 'localhost:3000'

  def sub_taken_notification(sub_request, new_shift)
    recipients  sub_request.shift.user.email
    from        "subtaken@app.stc.com"
    subject     "Your sub request has been taken by #{new_shift.user.name}"
    body        :sub_request => sub_request, :new_shift => new_shift
  end


  def password_reset_instructions(user)
    subject       "Password Reset Instructions"
    from          "Yale@yale.edu"
    recipients    user.email
    sent_on       Time.now
    body          :edit_password_reset_url => edit_password_reset_url(user.perishable_token)
  end

end
