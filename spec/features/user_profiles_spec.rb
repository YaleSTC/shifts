require 'rails_helper'

describe "User Profiles", :user do 
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

		context "When rendering profile fields of different types" do

			it "renders Text Field correctly" do 
				create_field_and_entry("text_field", @user, "text content")
				click_on "Edit"
				expect(page).to have_field(@profile_field.name, with: "text content", type: "text")
			end
			it "renders List correctly" do
				create_field_and_entry("select", @user,"s2", "s1, s2, s3")
				click_on "Edit"
				expect(page).to have_select(@profile_field.name, selected: "s2")
			end
			it "renders Multiple Choice correctly" do
				create_field_and_entry("radio_button", @user, "r2", "r1,r2,r3")
				click_on "Edit"
				expect(page).to have_checked_field("r2")
			end
			it "renders checkboxes correctly" do
				create_field_and_entry("check_box", @user, "c1,c2", "c1,c2, c3")
				click_on "Edit"
				expect(page).to have_checked_field("c1")
				expect(page).to have_checked_field("c2")
			end
			it "renders Paragraph Text correctly" do 
				create_field_and_entry("text_area", @user, "text area")
				click_on "Edit"
				expect(page).to have_selector("textarea", text: "text area")
			end
			it "renders picture link correctly" do 
				url = "http://weknowmemes.com/wp-content/uploads/2012/09/id-give-a-fuck-but.jpg"
				create_field_and_entry("picture_link", @user, url)
				visit current_path
				expect(page).to have_selector("img[src='#{url}']")
				click_on "Edit"
				expect(page).to have_field(@profile_field.name, with: url, type: "text")
			end
		end

		it "can update his editable profile fields (checkbox)" do
			create_field_and_entry("check_box", @user, "c1,c2", "c1,c2,c3, c4")
			click_on "Edit"
			check "c3"
			check "c4"
			uncheck "c1"
			uncheck "c2"
			click_on "Update"
			expect(page).to have_content("c3")
			expect(page).to have_content("c4")
		end
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
