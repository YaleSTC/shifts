require 'rails_helper'

describe "Group Jobs" do 
  before :each do 
    full_setup
    sign_in(@admin.login)
  end

  it "admin can create new group job" do 
    visit new_payform_item_set_path
    fill_in_date("payform_item_set_date", Date.today)
    choose "calculate_hours_user_input"
    select 2, from: "other_hours"
    select 30, from: "other_minutes"
    select @category.name, from: "Category"
    fill_in "Description", with: "A Test Group Job"
    select @superuser.name, from: "Select Users"
    select @user.name, from: "Select Users"
    click_on "Submit"
    expect_flash_notice("Successfully created payform item set")
    expect(PayformItemSet.count).to eq(1)
  end

  context "when a group job exists" do 
    before :each do 
      @pis = create(:payform_item_set, users: [@admin, @user])
    end

    it "displays correctly when one item is deleted" do 
      @pis.payform_items.first.update_attributes(active: false)
      visit payform_item_sets_path
      expect(page).to have_content("deleted from payform")
    end

    it "admin can remove user from group job" do 
      visit edit_payform_item_set_path(@pis)
      @payform = @admin.payforms.joins(payform_items: :payform_item_set).where(payform_item_sets: {id: @pis.id}).first
      unselect @admin.name, from: "Select Users"
      click_on "Submit"
      expect_flash_notice "Successfully updated payform item set"
      visit payform_path(@payform)
      expect(page).to have_content("removed you from this group job")
    end

    it "admin can add user to group job" do 
      visit edit_payform_item_set_path(@pis)
      select @superuser.name, from: "Select Users"
      click_on "Submit"
      expect_flash_notice "Successfully updated payform item set"
      expect(page).to have_link(@superuser.name, href: payform_path(@superuser.payforms.joins(payform_items: :payform_item_set).where(payform_item_sets: {id: @pis.id}).first))      
    end

    it "admin can edit group job" do 
      visit edit_payform_item_set_path(@pis)
      choose "calculate_hours_time_input"
      fill_in_time("time_input_start", Time.now)
      fill_in_time("time_input_end", Time.now+3.hours)
      click_on "Submit"
      expect_flash_notice "Successfully updated payform item set"
      expect(@pis.reload.hours).to eq(3)
    end

    it "admin can destroy group job"
  end

end
