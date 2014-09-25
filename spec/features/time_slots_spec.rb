require 'spec_helper'
require 'capybara/rails'

describe "timeslot creation process", :type => :feature do
  before :each do
    load Rails.root + "db/seeds.rb" 
    CASClient::Frameworks::Rails::Filter.fake("csw3") #spoof a CAS login
    # assume that it is Monday [specific date]
  end

  it "creates a timeslot" do
    visit '/time_slots/new'
    save_and_open_page
    within("#new_time_slot") do
      # fill_in DATE, :with => TOMORROW
      # fill_in time_slot_start_time_4i, :with => "10" #10am
      # ...more time
    end
    click_button 'Add'
    expect(page).to have_content 'Success'
  end

  xit "displays the timeslot properly" do
  end
end

def sign_in(netid)
    RubyCAS::Fake('csw3')
end

# feature 'Visitor signs up' do
#   scenario 'with valid email and password' do
#     sign_up_with 'valid@example.com', 'password'

#     expect(page).to have_content('Sign out')
#   end

#   scenario 'with invalid email' do
#     sign_up_with 'invalid_email', 'password'

#     expect(page).to have_content('Sign in')
#   end

#   scenario 'with blank password' do
#     sign_up_with 'valid@example.com', ''

#     expect(page).to have_content('Sign in')
#   end

#   def sign_up_with(email, password)
#     visit sign_up_path
#     fill_in 'Email', with: email
#     fill_in 'Password', with: password
#     click_button 'Sign up'
#   end
# end