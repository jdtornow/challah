AUTH_ROOT = File.expand_path(File.join(File.dirname(__FILE__), '..', '..'))

namespace :auth do
  desc "Setup the auth gem within this rails app."
  task :setup do
    puts "Copying migrations..."
    
    ENV['FROM'] = 'auth_engine'
    Rake::Task['railties:install:migrations'].invoke
  end
end