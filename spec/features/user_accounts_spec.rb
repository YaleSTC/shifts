require 'rails_helper'

describe "User accounts", :user do
	before(:each) do 
		full_setup
	end

	context "When admin is using Shifts" do 
		before(:each) do
			sign_in(@admin.login)
			visit department_users_path(@department)			
		end

		it "can view users page" do
			expect(page).to have_selector("h1", text: "Users")
		end

		it "can add new user" do
			click_on "Add A New User"
			new_user = attributes_for(:user)
			role = Role.first
			within '#user_form' do
				fill_in_user_form(new_user)
				# Checking the role
				find("[name='user[role_ids][]'][value='#{role.id}']").set(true)
				fill_in "Payrate", with: 12
			end
			expect{click_button "Create"}.to change{role.users.count}.by(1)
			expect_flash_notice("Successfully created user")
		end

		it "can find another user" do
			within '#user_searchbox' do
				fill_in "search", with: @user.login
				click_button "Submit"
			end
			expect(find('#user_list')).to have_css('tbody tr', count: 1)
		end

		# Strangely this test works only with selenium. WebKit cannot wait until the DB transaction happens, and Rack does not even wait till the page redirects.
		it "can update another user", driver: :selenium do
			click_on @user.login
			new_user = attributes_for(:user)
			#pp @new_user
			within "#user_form" do
				fill_in_user_form(new_user)
				fill_in "Payrate", with: 13				
			end
			expect{click_button "Update User"}.to change{@user.reload.login}
			expect_flash_notice "Successfully updated user"
		end

		it "can deactivate a user", js: true do
			find("#user#{@user.id}").click_on "Deactivate"
			expect(find("#user#{@user.id}")).to have_content("Restore")
			expect(@department.active_users).not_to include(@user.reload)
		end

		it "can activate a user", js: true do
			@user.toggle_active(@department)
			visit current_path
			click_on "Show Inactive Users"
			find("#user#{@user.id}").click_on "Restore"
			expect(find("#user#{@user.id}")).to have_content("Deactivate")
			expect(@department.active_users).to include(@user.reload)
		end
	end
end
