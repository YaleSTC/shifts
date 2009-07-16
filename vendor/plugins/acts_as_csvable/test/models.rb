class Client < ActiveRecord::Base
  has_many :projects
  
  def full_name
    self.first_name + " " + self.last_name
  end
end

class Project < ActiveRecord::Base
  belongs_to :client
  
  acts_as_csv_exportable :default, [{:project_name => :name}, {:project_description => :description}, {:client_name => 'client.full_name'}, {:deadline => 'formatted_deadline'}]
  acts_as_csv_exportable :simple, [:project_name => :name]
  
  acts_as_csv_importable :user_defined, [:id, :name, :description]
  acts_as_csv_importable :advanced, [:id, :name, :description, :find_client_from_name]
  
  def formatted_deadline
    self.deadline.strftime("%m/%d/%Y")
  end
  
  def find_client_from_name=(client_name)
    first_name = client_name.split.first
    last_name = client_name.split.last
    if(Client.find_by_first_name_and_last_name(first_name,last_name).blank?)
      self.client = Client.create(:first_name => first_name, :last_name => last_name)
    else
      self.client = Client.find(:first, :conditions => {:first_name => first_name, :last_name => last_name})
    end
  end
end