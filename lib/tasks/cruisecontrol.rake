#lib/tasks/cruisecontrol.rake
desc 'Run all continuous integration tests'
  task :cruise do
  #run all tests
  #see rails/lib/taks/testing.rake
  # errors = %w(units functionals integration javascripts acceptance).collect do |task|
  #   begin
  #     Rake::Task["test:#{task}"].invoke
  #     nil
  #   rescue => e
  #     task
  #   end
  # end.compact
  # abort "Errors running #{errors.to_sentence(:locale => :en)}!" if errors.any?

    system "cap deploy DOMAIN=mahi.its.yale.edu PREFIX=test BRANCH=master"
  end
