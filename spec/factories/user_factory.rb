FactoryGirl.define do

  factory :user do
    sequence(:login) {|n| "hp#{n}"}
    sequence(:first_name) {|n| "Harry##{n}"}
    last_name "Potter"
    nick_name "Scarhead"
    email {"#{login}@hogwarts.edu"}
    sequence(:employee_id, 6000000) {|n| "#{n}"} 
    # CAS authentication only
    auth_type "CAS"
    # Default value
    supermode true

    factory :admin do
      login "ad12"
      first_name "Albus"
      last_name "Dumbledore"
      nick_name "Bumblebee"
      superuser true
      # admin has admin_role
      before :create do |admin|
        admin.roles += Role.all.select{|r| r.name=='admin_role'}
      end
    end

    before :create do |user|
      user.set_random_password
      user.departments = [create(:department)]
      user.roles += Role.all.select{|r| r.name=="ordinary_role"}
    end

    #On create, UserObserver creates the default UserConfig, and an empty UserProfile
  end
end
