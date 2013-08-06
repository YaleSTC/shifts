# Kills a daemon rails server if one is running
desc 'stop rails'
task :stop do
  system('kill $(lsof -i :3000 -t)')
end

