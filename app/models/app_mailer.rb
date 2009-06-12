class AppMailer < ActionMailer::Base
  def sub_taken_notification(sub_request)
    recipients  sub_request.shift.user.email
    from        "subtaken@app.stc.com"
    subject     "Your sub request has been taken"
    body        :sub_request => sub_request
  end

end

