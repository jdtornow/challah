namespace :auth do
  desc "Setup the auth gem within this rails app."
  task :setup => [ "auth:setup:migrations", "db:migrate", "auth:setup:seeds" ]
  
  namespace :setup do
    desc "Copy migrations from auth gem"
    task :migrations do
      puts "Copying migrations..."    
      ENV['FROM'] = 'auth_engine'
      Rake::Task['railties:install:migrations'].invoke
    end
    
    desc "Load seed data"
    task :seeds => :environment do
      puts "Populating seed data..." 
      Auth::Engine.load_seed
    end
  end
end