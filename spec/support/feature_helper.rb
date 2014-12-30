require 'casclient'
require 'casclient/frameworks/rails/filter'


module FeatureHelper
  def sign_in(netid)
    RubyCAS::Filter.fake(netid)
  end

  # Equivalent to going through first-run setup
  def app_setup
    @app_config = create(:app_config)
    @department = create(:department)
    @superuser = create(:superuser)
  end

  # Does app_setup, creates a Location Group with a location, an ordinary role and an admin_role with default permissions, an ordinary user and an admin.
  def full_setup
    app_setup
    @loc_group = create(:loc_group)
    @location = create(:location, loc_group: @loc_group, category: @department.categories.where(name: "Shifts").first)
    @ord_role = create(:role)
    @admin_role = create(:admin_role)
    @admin = create(:admin)
    @user = create(:user)
  end

  # Capybara expectation helpers, does not modify browser state
  def expect_flash_notice(message, type="notice")
    expect(find("#flash_#{type}.alert")).to have_content(message)
  end

  # Capybara brower helpers, modifies browser state
  def fill_in_date(prefix, target_datetime)
    select target_datetime.year.to_s, :from => "#{prefix}_1i" 
    select Date::MONTHNAMES[target_datetime.month], :from => "#{prefix}_2i"
    select target_datetime.day.to_s, :from => "#{prefix}_3i"
  end
end

