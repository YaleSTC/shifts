require 'rails_helper'

describe "User Profiles" do 
	before :each do
		full_setup
	end

	context "When user is using Shifts" do
		before(:each) do
			sign_in(@user.login)
			visit user_profile_path(@user.login)
		end

		it "can upload a profile picture" do
			expect do
				click_on "Edit"
				attach_file "user_profile_photo", Rails.root.join("app/assets/images/fail_yale.jpg")
				click_on "Update"
				click_on "Crop"
			end.to change{find('div#profile_left img')["src"]}
		end

		context "When rendering profile fields of different type" do

			it "renders Text Field correctly"
			it "renders List correctly"
			it "renders Multiple Choice correctly"
			it "renders checkboxes correctly"
			it "renders Paragraph Text correctly"
			it "renders picture link correctly"
		end
		it "can update his editable profile fields"
		it "cannot update his non-editable profile fields"
		it "can see public profile fields"
		it "cannot see non-public profile fields"
		it "can see profile fields on index page"
		it "cannot see certain profile fields on index page"
	end
	context "When admin is using Shifts" do 
		before(:each) {sign_in(@admin.login)}
		# xit "displays user profile fields" do
		# 	visit user_profile_fields_path
		# 	save_and_open_page
		# end

		it "can create a profile field"
		it "can edit a profile field"
		it "can destroy a profile field"
		it "can update the profile of another user"
	end
end
