require 'rails_helper'

describe "Location Groups" do 
	before :each do 
		full_setup
		sign_in(@admin.login)
	end

	it "can create new location group"

	context "For existing location group" do 
		it "can update location group"
		it "can deactivate location group"
		it "can re-activate location group"
		it "can delete location group"
	end
	
end
