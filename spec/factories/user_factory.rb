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

    # If admin factory is called with create, the department and the admin_role will be created as well, if not already created.
    factory :admin do
      login "ad12"
      first_name "Albus"
      last_name "Dumbledore"
      nick_name ""
      
      # Give admin_role to admin if saving to Database
      before :create do |admin|
        admin.roles << create(:admin_role)
      end
    end

    factory :superuser do
        login "tmr42"
        first_name "Lord"
        last_name "Voldemort"
        nick_name "He-Who-Must-Not-Be-Named"
        superuser true
    end

    after :build do |user|
      user.set_random_password
      user.departments = [create(:department)]
    end
      
    # Give ordinary_role (if exists) to user if saving to Database
    before :create do |user|
      r =  Role.where(name: "ordinary_role").first
      user.roles << r if not r.nil?
    end
    #On create, UserObserver creates the default UserConfig, and an empty UserProfile
  end
end
