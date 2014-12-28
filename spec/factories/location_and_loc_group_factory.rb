FactoryGirl.define do
  factory :loc_group, class: LocGroup do
    department
    sequence(:name) {|n| "Public Cluster #{n}"}
    # No need to create permissions here since it is automatic in loc_group model
  end

  factory :location do
    category 
    loc_group
    sequence (:name) {|n| "Technology Troubleshooting Office #{n}"}
    sequence (:short_name) {|n|"TTO#{n}"}
    description "students come here when things break"
    max_staff 2
    min_staff 1
    priority 1
    active true
  end
end
