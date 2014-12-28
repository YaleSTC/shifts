require 'casclient'
require 'casclient/frameworks/rails/filter'


module FeatureHelper
  def sign_in(netid)
    RubyCAS::Filter.fake(netid)
  end

  def app_setup
    @app_config = create(:app_config)
    @department = create(:department)
    @loc_group = create(:loc_group, department: @department)
    @location = create(:location, loc_group: @loc_group)
    @ord_role = create(:role)
    @admin_role = create(:admin_role)
    @admin = create(:admin)
  end


  # Capybara brower helpers, modifies browser state
  def fill_in_date(prefix, target_datetime)
    select target_datetime.year.to_s, :from => "#{prefix}_1i" 
    select Date::MONTHNAMES[target_datetime.month], :from => "#{prefix}_2i"
    select target_datetime.day.to_s, :from => "#{prefix}_3i"
  end
end

