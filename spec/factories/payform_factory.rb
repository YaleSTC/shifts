include TimeHelper

FactoryGirl.define do 
  factory :payform do 
    ignore do 
      payform_items_count 0
    end
    department
    user
    date {local_date}
    initialize_with {Payform.build(department, user, date)}
    after :create do |p, evaluator|
      create_list(:payform_item, evaluator.payform_items_count, payform: p)
    end
  end

  factory :payform_item do 
    category
    active true
    payform
    date {local_date}
    hours 1
    sequence(:description){|n| "Payform Item #{n}"}
  end

  factory :payform_set do 
    department
    ignore do 
      payforms {[create(:payform, approved: true, submitted: true)]}
    end
    after :build do |ps, evaluator|
      ps.payforms = evaluator.payforms
      ps.payforms.map{|p| p.printed = true}
    end
  end

  factory :payform_item_set do 
    ignore do 
      users {[create(:user)]}
    end
    category
    date {local_date}
    hours 1
    sequence(:description){|n| "Group Job #{n}"}
    active true
    after :build do |pis, evaluator|
      evaluator.users.each do |u|
        payform = create(:payform, user: u, date: pis.date)
        item = create(:payform_item, category: pis.category, date: pis.date, hours: pis.hours, description: pis.description, payform: payform, reason: "Added as Group Job")
        pis.payform_items << item
      end
    end
  end
end
