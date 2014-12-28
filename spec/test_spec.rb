# Specs to debug the test suit setup

require 'rails_helper'

describe "testing department factory" do
	xit "does not create two departments" do
		d1=create(:department)
		d2=create(:department)
		expect(d1).to eq(d2)
	end

	xit "creates location categories" do 
		pp create(:location)
		pp Category.all
		#pp Location.first
		pp Location.first.category
	end	

	xit "creates two departments" do
		pp create(:department)
		pp create(:department, name: "askdfjsdakf")
		pp create(:department)
		pp create(:department, name: "askdfjsdakf")
		pp Department.all
	end

	xit "app_setup" do
		app_setup
		pp Role.all 
	end

	xit "department creation creates roles" do
		pp create(:role)
		pp create(:admin_role)
		pp create(:role, name: "new_role")
		pp create(:admin_role)
		pp Role.all
		pp Role.all.collect &:department
	end

	xit "user factory" do
		create_list(:user,300)
		create(:admin)
		pp "#{Department.all.count} department(s)"
		pp "#{User.count} user(s)"
	end
end
