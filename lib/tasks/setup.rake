namespace :challah do
  desc "Setup the challah gem within this rails app."
  task :setup => [ "challah:setup:migrations", "challah:unpack:user", "db:migrate", "challah:setup:seeds", "challah:users:create", "challah:banner" ]

  task :banner do
    banner = <<-str

  ==========================================================================
  Challah has been set up successfully!

  Your app now has a User model that is ready to go.

  And some new routes set up for /sign-in and /sign-out. You can use these
  for the built-in log in page or roll your own if you'd prefer.

  The user that you just created is ready to log in.

  ==========================================================================

    str

    puts banner
  end

  desc "Insert the default users, roles and permissions."
  task :seeds => [ "challah:setup:seeds" ]

  namespace :setup do
    task :migrations do
      puts "Copying migrations..."
      Rake::Task['challah_engine:install:migrations'].invoke
    end

    task :seeds => :environment do
      puts "Populating seed data..."
      Challah::Engine.load_seed
    end
  end
end