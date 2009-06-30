class AppMailer < ActionMailer::Base
  def sub_taken_notification(sub_request, new_shift)
    recipients  sub_request.shift.user.email
    from        "subtaken@app.stc.com"
    subject     "Your sub request has been taken by #{new_shift.user.name}"
    body        :sub_request => sub_request, :new_shift => new_shift
  end

  def payform_item_change_notification(old_payform_item, new_payform_item = nil)
    recipients  old_payform_item.payform.user.email
    from        "payformitemchanged@app.stc.com"
    if new_payform_item == nil && !old_payform_item.active
    subject     "Your payform item has been changed by #{}"
end
