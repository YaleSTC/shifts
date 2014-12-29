require 'rails_helper'

describe "First Run Application Configuration" do 
	context "When using CAS authentication, no LDAP", :user do
		before :all do 
			@superuser_attrs = attributes_for(:superuser)
			@dpmt_attrs = attributes_for(:department)
			sign_in(@superuser_attrs[:login])
		end

		it "completes the first run config page" do 
			visit '/'
			# AppConfig
			within "#new_app_config" do
				select "CAS", from: "app_config_auth_types"
				uncheck "ldap_check_box"
				fill_in "App email address", with: @superuser_attrs[:email]
				fill_in "Admin email address", with: @superuser_attrs[:email]
				fill_in "Footer Text", with: "<b>Bold App Footer</b><br><i>Italic App Footer 2</i>"
			end
			expect{click_button "Submit"}.to change{AppConfig.count}.from(0).to(1)
			expect_flash_notice "App Settings have been configured"
			
			# New Department
			within('#new_department'){fill_in "Name", with: @dpmt_attrs[:name]}
			expect{click_button "Submit"}.to change{Department.count}.from(0).to(1)
			expect_flash_notice "The first department was successfully created"

			# Superuser
			within('#first_user_form') {fill_in_user_form(@superuser_attrs)}
			expect{click_button "Submit"}.to change{User.count}.from(0).to(1)
			expect_flash_notice "Successfully set up application"
		end

	end
end
