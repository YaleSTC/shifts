require 'rails_helper'

describe "access permissions of pages" do 
	before(:each){full_setup}
	def expect_access_denied
		expect(page).to have_selector("h1", text: "Access Denied")
	end

	context "as department admin" do 
		before(:each){sign_in(@admin.login)}
		it "cannot access application configuration page" do 
			visit edit_app_config_path
			expect_access_denied
		end
		it "cannot access department index/show/edit/new page" do 
			visit departments_path
			expect_access_denied
			visit department_path(@department)
			expect_access_denied
			visit edit_department_path(@department)
			expect_access_denied
			visit new_department_path
			expect_access_denied
		end

		it "cannot access permissions index page" do 
			visit permissions_path
			expect_access_denied
		end
		it "cannot access superusers index page" do 
			visit superusers_path
			expect_access_denied
		end
	end
	context "as ordinary user" do 
		before(:each){sign_in(@user.login)}
		it "cannot access users index page" do 
			visit users_path
			expect_access_denied
		end
		it "cannot access user edit page" do 
			visit edit_user_path(@user)
			expect_access_denied
		end
	end
	context "as superuser" do 
		before(:each){sign_in(@superuser.login)}
		it "cannot access first_run pages" do 
			visit first_app_config_path
			expect_access_denied
			visit first_department_path
			expect_access_denied
			visit first_user_path
			expect_access_denied
		end
	end
end
