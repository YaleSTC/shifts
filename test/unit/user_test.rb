# == Schema Information
#
# Table name: users
#
#  id                    :integer          not null, primary key
#  login                 :string(255)
#  first_name            :string(255)
#  last_name             :string(255)
#  nick_name             :string(255)
#  employee_id           :string(255)
#  email                 :string(255)
#  crypted_password      :string(255)
#  password_salt         :string(255)
#  persistence_token     :string(255)
#  auth_type             :string(255)
#  perishable_token      :string(255)      default(""), not null
#  default_department_id :integer
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  superuser             :boolean
#  supermode             :boolean          default(TRUE)
#  calendar_feed_hash    :string(255)
#

require 'test_helper'

class UserTest < ActiveSupport::TestCase
  def test_should_be_valid
    assert User.new.valid?
  end
end
