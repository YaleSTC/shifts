namespace :db do
  desc "Delete payforms of all Users."

  def delete_payforms_for_users(department_name)
  	puts "Starting payform deletion..."
  	department = Department.where(:name => department_name).first
    users = User.all.select{|u| u.departments.include?(department)}
    users.each do |user|
    	user.payforms.each do |payform|
      	if !payform.destroy
        	puts "Payform #{payform.id} not destroyed! The error message:"
        	payform.errors.full_messages.each do |message|
          	puts message
          end
        end
      end
    end
    puts "Payform deletion process complete."
  end


  desc "Rewrite profiles with empty instances of all department profile fields"
  task :delete_payforms, [:department_name] => :environment do |t, args|
    department_name = args[:department_name]
    delete_payforms_for_users(department_name)
  end
end