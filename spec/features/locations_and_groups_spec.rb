require 'rails_helper'

describe "Location Groups" do 
	before :each do 
		full_setup
		@location2 = create(:location, loc_group: @loc_group)
		sign_in(@admin.login)
	end

	it "can create new location group" do 
		visit department_loc_groups_path(@department)
		within '#new_loc_group' do 
			fill_in "Name", with: "New Location Group"
			uncheck "Public"
			click_on "Create"
		end
		expect_flash_notice "Successfully created location group"
		expect(LocGroup.count).to eq(2)
	end

	context "For existing location group" do 
		it "can update location group" do 
			visit edit_loc_group_path(@loc_group)
			uncheck "Public"
			click_on "Update"
			expect_flash_notice "Successfully updated Location group"
			expect{@loc_group.reload}.to change(@loc_group, :public)
		end
		it "can deactivate location group", js: true do 
			visit department_loc_groups_path(@department)
			find("tr#loc_group#{@loc_group.id}").click_on "Deactivate"
			expect(find("tr#loc_group#{@loc_group.id}")).to have_content("Restore")
			expect(@loc_group.reload.active).to be false
			@loc_group.locations.each do |loc|
				expect(loc.active).to be false
			end
		end
		it "can re-activate location group", js: true do 
			@loc_group.deactivate
			visit department_loc_groups_path(@department)
			find("tr#loc_group#{@loc_group.id}").click_on "Restore"
			expect(find("tr#loc_group#{@loc_group.id}")).to have_content("Deactivate")
			expect(@loc_group.reload.active).to be true
			@loc_group.locations.each do |loc|
				expect(loc.active).to be true
			end			
		end
		it "can delete location group" do 
			visit loc_group_path(@loc_group)
			# There are other Destroy links to destroy locations in the table
			all('a', text: "Destroy").last.click
			expect_flash_notice "Successfully destroyed Location group"
			expect{@loc_group.reload}.to raise_error(ActiveRecord::RecordNotFound)
		end
	end
end

describe "Locations" do 
	before :each do 
		full_setup
		sign_in(@admin.login)
	end

	it "can create new locations"

	context "For existing locations" do 
		it "can update location"

		it "can deactivate location"

		it "can re-activate location"

		it "can delete location"
	end
end
