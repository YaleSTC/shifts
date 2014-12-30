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

		context "When having profile fields of different types" do

			def expect_to_render_and_update_correctly(type, values="")
				profile_field = create(:user_profile_field, display_type: type, values: values)
				profile_entry = UserProfileEntry.where(user_profile_id: @user.user_profile.id, user_profile_field_id: profile_field.id).first
			 	visit edit_user_profile_path(@user.login)
			 	yield profile_field, profile_entry
			 	expect{profile_entry.reload}.to change{profile_entry.content}
			end

			it "renders and updates Text Field correctly" do 
				expect_to_render_and_update_correctly(:text_field) do |field, entry|
					content = "text content"
					fill_in field.name, with: content
					click_on "Update"
					expect(page).to have_content(content)
				end
			end
			it "renders and updates List correctly" do
				expect_to_render_and_update_correctly(:select, "s1, s2, s3") do |field, entry|
					content = "s2"
					select content, from: field.name
					click_on "Update"
					expect(page).to have_content(content)
				end
			end
			it "renders and updates Multiple Choice correctly" do
				expect_to_render_and_update_correctly(:radio_button, "r1,r2,r3") do |field, entry|
					(1..3).each {|i| expect(page).to have_field("r#{i}")}
					choose "r3"
					click_on "Update"
					expect(page).to have_content("r3")
				end
			end
			it "renders and updates checkboxes correctly" do
				expect_to_render_and_update_correctly(:check_box, "c1,c2, c3") do |field, entry|
					check "c1"; uncheck "c2"; check "c3"; click_on "Update"
					expect(page).not_to have_content("c2")
					expect(page).to have_content("c1")
					expect(page).to have_content("c3")
				end
			end
			it "renders and updates Paragraph Text correctly" do 
				expect_to_render_and_update_correctly(:text_area) do |field, entry|
					content = "text area"
					find("textarea").set(text: content)
					click_on "Update"
					expect(page).to have_content(content)
				end
			end
			it "renders and updates picture link correctly" do 
				expect_to_render_and_update_correctly(:picture_link) do |field, entry|
					url = "http://weknowmemes.com/wp-content/uploads/2012/09/id-give-a-fuck-but.jpg"
					fill_in field.name, with: url
					click_on "Update"
					expect(page).to have_selector("img[src='#{url}']")
				end
			end
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
