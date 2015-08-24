require 'rails_helper'

describe "CSV import" do 
  before(:each) do 
    full_setup
    sign_in(@admin.login)
  end

	it 'should import users in correct format' do
		# CSV file has two users with valid roles, one with invalid role.
		# Expected behavior: import two, fail to import the third, display errors.
		visit users_path
		click_link('Import from CSV')
		attach_file('file', Rails.root + 'spec/fixtures/user_import.csv')
		expect {
			click_button 'Upload'
		}.to change {
			User.count
		}.by(2)
		expect(page).to have_content('Invalid role', count: 1) # exactly one error
	end
end
