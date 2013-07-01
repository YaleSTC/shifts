require 'test_helper'

class UserMailerTest < ActionMailer::TestCase
  def password_reset_instructions
    user = users(:users_001)
 
    # Send the email, then test that it got queued
    email = UserMailer.password_reset_instructions(user).deliver
    assert !ActionMailer::Base.deliveries.empty?
 
    # Test the body of the sent email contains what we expect it to
    assert_equal [user.email], email.to
    assert_equal "Password Reset Instructions", email.subject
    assert_match("A request to reset your password has been made.", email.encoded)
  end

  def admin_password_reset_instructions
  	user = users(:users_002)

    email = UserMailer.admin_password_reset_instructions(user).deliver
    assert !ActionMailer::Base.deliveries.empty?

    assert_equal [user.email], email.to
    assert_equal "Password Reset Instructions", email.subject
    assert_match("A request to reset your password has been made.", email.encoded)
  end

  def new_user_password_instructions
  	user = users(:users_003)
  	department = departments(:depatrment_001)

	email = UserMailer.new_user_password_instructions(user).deliver
    assert !ActionMailer::Base.deliveries.empty?

    assert_equal [user.email], email.to
    assert_equal "Password Reset Instructions", email.subject
    assert_match("A request to reset your password has been made.", email.encoded)
  end
end