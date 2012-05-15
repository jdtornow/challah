module Challah
  module Task
    require 'fileutils'

    def self.unpack_file(source, destination = nil)
      destination = source if destination.nil?

      unless defined?(Rails)
        raise "Rails could not be found. Are you sure you are in a Rails project?"
      end

      from = File.expand_path(File.join(File.dirname(__FILE__), '..', '..', source))
      to = File.expand_path(File.join(Rails.root, destination))

      if File.exists?(from)
        if File.exists?(to)
          puts "exists     #{destination}"
        else
          FileUtils.mkdir_p(File.dirname(to))
          FileUtils.cp(from, to)

          puts "created    #{destination}"
        end
      end
    end
  end
end

namespace :challah do
  namespace :unpack do
    desc "Unpack the User model, Role model, Sessions controller and sign in views to the app"
    task :all => [ :permission, :role, :user, :signin, :views ]

    desc "Copy the default Permission model into the app"
    task :permission do
      Challah::Task.unpack_file('app/models/permission.rb')
    end

    desc "Copy the sign in and access denied views into the app"
    task :signin do
      Challah::Task.unpack_file('app/controllers/sessions_controller.rb')
    end

    desc "Copy the default Role model into the app"
    task :role do
      Challah::Task.unpack_file('app/models/role.rb')
    end

    desc "Copy the default User model into the app"
    task :user do
      Challah::Task.unpack_file('app/models/user.rb')
    end

    desc "Copy the sign in and access denied views into the app"
    task :views do
      Challah::Task.unpack_file('app/views/sessions/new.html.erb')
      Challah::Task.unpack_file('app/views/sessions/access_denied.html.erb')
    end
  end

  task :unpack => "unpack:all"
end