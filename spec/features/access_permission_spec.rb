describe "access permissions of pages" do 
	before(:each){full_setup}
	context "as department admin" do 
		before(:each){sign_in(@admin.login)}
		it "cannot access application configuration page"
		it "cannot access department index/edit/new page"
		it "cannot access permissions index page"
		it "cannot access superusers index page"
	end
	context "as ordinary user" do 
		before(:each){sign_in(@user.login)}
		it "cannot access users index page"
		it "cannot access user edit page"
	end
end
