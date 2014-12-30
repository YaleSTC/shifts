# Specs to debug the test suit setup

require 'rails_helper'

# Testing Factories
# If using RSpec 2.x, remove `RSpec.`
RSpec.describe "Factory Girl" do
  FactoryGirl.factories.map(&:name).each do |factory_name|
    describe "#{factory_name} factory" do

      # Test each factory
      it "is valid" do
        factory = FactoryGirl.build(factory_name)
        if factory.respond_to?(:valid?)
          # the lamba syntax only works with rspec 2.14 or newer;  for earlier versions, you have to call #valid? before calling the matcher, otherwise the errors will be empty
          expect(factory).to be_valid, lambda { factory.errors.full_messages.join("\n") }
        end
      end

      # Test each trait
      FactoryGirl.factories[factory_name].definition.defined_traits.map(&:name).each do |trait_name|
        context "with trait #{trait_name}" do
          it "is valid" do
            factory = FactoryGirl.build(factory_name, trait_name)
            if factory.respond_to?(:valid?)
              expect(factory).to be_valid, lambda { factory.errors.full_messages.join("\n") }
            end
          end
        end
      end

    end
  end
end

describe "testing factory" do
# 	xit "does not create two departments" do
# 		d1=create(:department)
# 		d2=create(:department)
# 		expect(d1).to eq(d2)
# 	end

# 	xit "creates location categories" do 
# 		pp create(:location)
# 		pp Category.all
# 		#pp Location.first
# 		pp Location.first.category
# 	end	

# 	xit "creates two departments" do
# 		pp create(:department)
# 		pp create(:department, name: "askdfjsdakf")
# 		pp create(:department)
# 		pp create(:department, name: "askdfjsdakf")
# 		pp Department.all
# 	end

# 	xit "app_setup" do
# 		app_setup
# 		pp Role.all 
# 	end

# 	xit "department creation creates roles" do
# 		pp create(:role)
# 		pp create(:admin_role)
# 		pp create(:role, name: "new_role")
# 		pp create(:admin_role)
# 		pp Role.all
# 		pp Role.all.collect &:department
# 	end

# 	xit "user factory" do
# 		create_list(:user,300)
# 		create(:admin)
# 		pp "#{Department.all.count} department(s)"
# 		pp "#{User.count} user(s)"
# 	end

#   xit "has one department, built-in categories" do
#     full_setup
#     pp Department.count
#     pp Category.all
#     pp Location.first
#     pp Location.first.category
#   end
  # xit "creates user_profile_field" do
  #   user = create(:admin)
  #   f = create(:user_profile_entry, user: user);
  #   pp user.user_profile.user_profile_entries
  #   pp User.all
  # end
end
