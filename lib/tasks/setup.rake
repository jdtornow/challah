AUTH_ROOT = File.expand_path(File.join(File.dirname(__FILE__), '..', '..'))

namespace :auth do
  desc "Setup the auth gem within this rails app."
  task :setup => :environment do
    puts "Copying migrations..."
    
    ENV['FROM'] = 'auth_engine'
    Rake::Task['railties:install:migrations'].invoke
    
    puts "Populating seed data..."
    
    Auth::Engine.load_seed
  end
end