require 'rails_helper'

describe "First Run Application Configuration" do 
	context "When using CAS authentication, no LDAP" do
		before :all do 
			@admin_attrs = attributes_for(:admin)
			@dpmt_attrs = attributes_for(:department)
			sign_in(@admin_attrs[:login])
		end

		it "shows the first run config page" do 
			visit '/'
			# AppConfig
			within "#new_app_config" do
				select "CAS", from: "app_config_auth_types"
				uncheck "ldap_check_box"
				fill_in "App email address", with: @admin_attrs[:email]
				fill_in "Admin email address", with: @admin_attrs[:email]
				fill_in "Footer Text", with: "<b>Bold App Footer</b><br><i>Italic App Footer 2</i>"
			end
			expect{click_button "Submit"}.to change{AppConfig.count}.from(0).to(1)
			expect_flash_notice "App Settings have been configured"
			
			# New Department
			within '#new_department' do
				fill_in "Name", with: @dpmt_attrs[:name]
			end
			expect{click_button "Submit"}.to change{Department.count}.from(0).to(1)
			expect_flash_notice "The first department was successfully created"

			# Superuser
			within '#first_user_form' do
				fill_in "Login", with: @admin_attrs[:login]
				fill_in "First name", with: @admin_attrs[:first_name]
				fill_in "Nick name", with: @admin_attrs[:nick_name]
				fill_in "Last name", with: @admin_attrs[:last_name]
				fill_in "Email", with: @admin_attrs[:email]
				fill_in "Employee ID", with: @admin_attrs[:employee_id]
			end
			expect{click_button "Submit"}.to change{User.count}.from(0).to(1)
			expect_flash_notice "Successfully set up application"
		end

	end
end
