# == Schema Information
#
# Table name: app_configs
#
#  id                 :integer          not null, primary key
#  footer             :string(255)
#  auth_types         :string(255)
#  ldap_host_address  :string(255)
#  ldap_port          :integer
#  ldap_base          :string(255)
#  ldap_login         :string(255)
#  ldap_first_name    :string(255)
#  ldap_last_name     :string(255)
#  ldap_email         :string(255)
#  use_ldap           :boolean
#  mailer_address     :string(255)
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  calendar_feed_hash :string(255)
#  admin_email        :string(255)
#

require File.dirname(__FILE__) + '/../spec_helper'

describe AppConfig do
  it "should be valid" do
    AppConfig.new.should be_valid
  end
end
