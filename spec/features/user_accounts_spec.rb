require 'rails_helper'

describe "User accounts" do
	before(:each) do 
		app_setup
		@user = create(:user)
	end
	context "When admin is using Shifts" do 
		before(:each) {sign_in(@admin.login)}
		it "can view users page"
		it "can add new users"
		it "can update another user"
		it "can deactivate a user"
		it "can activate a user"
	end
	context "When ordinary user is using Shifts" do
		before(:each) {sign_in(@user.login)}
		it "can update itself"
	end
end
