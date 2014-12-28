FactoryGirl.define do
  factory :user do
    login "ad12"
    first_name "Albus"
    last_name "Dumbledore"
    nick_name "Albus"
    email "ad12@hogwarts.edu"
    auth_type "CAS"
    default_department_id 1

    factory :admin do
      superuser true
      # admin has admin_role
      before :create do |admin|
        #admin.roles ||= []
        admin.roles += Role.all.select{|r| r.name=='admin_role'}
      end
    end

    before :create do |obj|
      obj.set_random_password
      obj.departments << Department.find(1)

      # Set roles
      #obj.roles ||= []
      obj.roles += Role.all.select{|r| r.name=="ordinary_role"}
    end
  end
end
