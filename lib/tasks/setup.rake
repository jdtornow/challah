namespace :challah do
  desc "Setup the challah gem within this rails app."
  task :setup => [ "challah:setup:migrations", "db:migrate", "challah:setup:seeds" ]
  
  namespace :setup do
    desc "Copy migrations from challah gem"
    task :migrations do
      puts "Copying migrations..."    
      ENV['FROM'] = 'challah_engine'
      Rake::Task['railties:install:migrations'].invoke
    end
    
    desc "Load seed data"
    task :seeds => :environment do
      puts "Populating seed data..." 
      Challah::Engine.load_seed
    end
  end
end