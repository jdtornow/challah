namespace :challah do
  desc "Setup the challah gem within this rails app."
  task :setup => [ "challah:setup:migrations", "challah:unpack:user", "db:migrate", "challah:banner" ]

  task :banner do
    is_rails5 = Rails.version.start_with? "5"

    cmd = is_rails5 ? "rails" : "rake"

    banner = <<-str

  ==========================================================================
  Challah has been set up successfully!

  Your app now has a User model that is ready to go.

  And some new routes set up for /sign-in and /sign-out. You can use these
  for the built-in log in page or roll your own if you'd prefer.

  If you want to create a new user now, just run:

  #{ cmd } challah:users:create

  ==========================================================================

    str

    puts banner
  end

  namespace :setup do
    task :migrations do
      puts "Setting up migrations..."
      sh "rails generate challah"
    end
  end
end
