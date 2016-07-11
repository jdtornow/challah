namespace :challah do
  desc "Setup the challah gem within this rails app."
  task :setup => [ "challah:setup:migrations", "challah:unpack:user", "db:migrate", "challah:banner" ]

  task :banner do
    banner = <<-str

  ==========================================================================
  Challah has been set up successfully!

  Your app now has a User model that is ready to go.

  And some new routes set up for /sign-in and /sign-out. You can use these
  for the built-in log in page or roll your own if you'd prefer.

  If you want to create a new user now, just run:

  rails challah:users:create

  ==========================================================================

    str

    puts banner
  end

  namespace :setup do
    task :migrations do
      puts "Copying migrations..."
      Rake::Task["challah_engine:install:migrations"].invoke
    end
  end
end
