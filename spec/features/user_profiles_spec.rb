require 'rails_helper'

describe "User Profiles" do 
	before :each do
		full_setup
	end
	context "When admin is using Shifts" do 
		before(:each) {sign_in(@admin.login)}
		it "displays user profile fields" do
			visit user_profile_fields_path
			save_and_open_page
		end
	end
	context "When user is using Shifts" do
		before(:each) do
			sign_in(@user.login)
			visit user_profile_path(@user.login)
			# create profile fields

		end

		it "can upload a profile picture" do
			expect do
				click_on "Edit"
				attach_file "user_profile_photo", Rails.root.join("app/assets/images/fail_yale.jpg")
				click_on "Update"
				click_on "Crop"
			end.to change{find('div#profile_left img')["src"]}
		end

		it "can update his editable profile fields"
		it "cannot update his non-editable profile fields"
		it "cannot see non-public profile fields"
	end
end
