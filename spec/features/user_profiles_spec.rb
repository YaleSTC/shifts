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

		context "When rendering profile fields of different types" do

			def create_field_and_entry(display_type, content, values="")
				profile_field = create(:user_profile_field, display_type: display_type, values: values)
				profile_entry = create(:user_profile_entry, user: @user, user_profile_field: profile_field, content: content)
				return profile_field.name
			end

			it "renders Text Field correctly" do 
				content = "text content"
				name = create_field_and_entry("text_field", content)
				click_on "Edit"
				expect(page).to have_field(name, with: content, type: "text")
			end
			it "renders List correctly" do
				content = "s2"
				name = create_field_and_entry("select", content, "s1, s2, s3")
				click_on "Edit"
				expect(page).to have_select(name, selected: content)
			end
			it "renders Multiple Choice correctly" do
				content = "r2"
				name = create_field_and_entry("radio_button", content, "r1,r2,r3")
				click_on "Edit"
				expect(page).to have_checked_field(content)
			end
			it "renders checkboxes correctly" do
				content = "c2"
				name = create_field_and_entry("check_box", content, "c1,c2, c3")
				click_on "Edit"
				expect(page).to have_checked_field(content)
			end
			it "renders Paragraph Text correctly" do 
				content = "text area"
				name = create_field_and_entry("text_area", content)
				click_on "Edit"
				expect(page).to have_selector("textarea", text: content)
			end
			it "renders picture link correctly" do 
				content = "http://weknowmemes.com/wp-content/uploads/2012/09/id-give-a-fuck-but.jpg"
				name = create_field_and_entry("picture_link", content)
				click_on "Edit"
				expect(page).to have_field(name, with: content, type: "text")
			end
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
