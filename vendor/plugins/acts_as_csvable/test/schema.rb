require File.dirname(__FILE__) + '/models'
ActiveRecord::Schema.define(:version => 1) do 
  create_table :clients, :force => true do |t|
    t.string :first_name
    t.string :last_name
    t.datetime :birth_date
  end
  
  create_table :projects, :force => true do |t|
    t.belongs_to :client
    t.string :name
    t.string :description
    t.datetime :deadline
  end
  
  c = Client.create(:first_name => "Peter", :last_name => "Leonhardt")
  Project.create(:name => "Test Project", :description => "Used for Testing", :deadline => Time.now, :client => c)
end