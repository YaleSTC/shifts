require 'rails_helper'

describe "User Profiles", :user do 
	before :each do
		full_setup
	end

	context "When user is using Shifts" do
		before(:each) {sign_in(@user.login)}

		it "can upload a profile picture" do
			visit user_profile_path(@user.login)
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

		it "cannot update his non-editable profile fields" do 
			field = create(:user_profile_field, user_editable: false)
			entry = UserProfileEntry.where(user_profile_field_id: field.id, user_profile_id: @user.user_profile.id).first
			content = "Not editable"
			entry.update_attribute(:content, content)
			visit user_profile_path(@user.login)
			expect(page).to have_content(content)
			click_on "Edit"
			expect(page).not_to have_field(field.name)
		end

		it "cannot see non-public profile fields" do 
			field = create(:user_profile_field, public: false)
			entry = UserProfileEntry.where(user_profile_field_id: field.id, user_profile_id: @admin.user_profile.id).first
			content = "Not public"
			entry.update_attribute(:content, content)
			visit user_profile_path(@admin.login)
			expect(page).not_to have_content(content)
		end
		it "can see profile fields on index page" do
			field = create(:user_profile_field)
			visit user_profiles_path
			expect(page).to have_content(field.name)
		end
		it "cannot see certain profile fields on index page" do 
			field = create(:user_profile_field, index_display: false)
			visit user_profiles_path
			expect(page).not_to have_content(field.name)
		end
	end
	context "When admin is using Shifts" do 
		before(:each) {sign_in(@admin.login)}

		it "can create a profile field" do 
			visit new_user_profile_field_path
			fill_in "Name", with: "Favorite Programming Language"
			select "Multiple Choice", from: "Display type"
			fill_in "Values", with: "C, C++, Objective C, Java, JavaScript, Ruby, Python"
			uncheck "Displayed in Index?"
			check "Public?"
			check "User Editable?"
			click_button "Submit"
			expect_flash_notice "Successfully created user profile field"
			expect(UserProfileField.last.name).to eq("Favorite Programming Language")
		end
		it "can edit a profile field" do 
			field = create(:user_profile_field, display_type: "text_area")
			visit user_profile_fields_path
			click_on "Edit"
			select "Check Boxes", from: "Display type"
			fill_in "Values", with: "a,b, c,  d  ,e"
			click_button "Submit"
			expect(field.reload.display_type).to eq("check_box")
		end

		# Only selenium can handle alert popups
		it "can destroy a profile field" , driver: :selenium do 
			create(:user_profile_field)
			visit user_profile_fields_path
			id = page.all('td a', text: "Destroy")[0]["href"].match(/(\d+)$/)[1].to_i
			click_on "Destroy"
			# If using selenium driver
			alert = page.driver.browser.switch_to.alert
			alert.accept
			expect_flash_notice "Successfully destroyed user profile field"
			expect{UserProfileField.find(id)}.to raise_error(ActiveRecord::RecordNotFound)
		end
		it "can update the profile of another user" do 
			field = create(:user_profile_field)
			entry = UserProfileEntry.where(user_profile_field_id: field.id, user_profile_id: @user.user_profile.id).first
			visit edit_user_profile_path(@user.login)
			fill_in field.name, with: "test entry"
			click_button "Update"
			expect(entry.reload.content).to eq("test entry")
		end
	end
end
