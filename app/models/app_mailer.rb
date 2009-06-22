class AppMailer < ActionMailer::Base
  def sub_taken_notification(sub_request, new_shift)
    recipients  sub_request.shift.user.email
    from        "subtaken@app.stc.com"
    subject     "Your sub request has been taken by #{new_shift.user.name}"
    body        :sub_request => sub_request, :new_shift => new_shift
  end

end

