require 'highline/import'

namespace :challah do
  namespace :users do
    desc "Create a new user"
    task :create => :environment do
      check_for_tables

      first_user = ::User.count == 0

      banner('Creating a user')

      if first_user
        puts "Please answer the following questions to create your first admin user.\n\n"
      end

      # Grab the required fields.
      first_name = ask('First name: ')
      last_name = ask('Last name: ')
      email = ask('Email: ')
      username = ask('Username: ') { |q| q.default = email }
      password = ask_for_password

      role_id = 0

      # If Roles are included (challah-rolls) ask for the role here.
      if defined?(::Role) and check_for_roles
        role_id = Role.admin.id

        # First user is always going to be an admin, otherwise ask for the role
        unless first_user
          choose do |menu|
            menu.prompt = 'Choose a role for this user: '

            Role.all.each do |role|
              menu.choice(role.name) { role_id = role.id }
            end
          end
        end
      end

      user = ::User.new
      user.first_name = first_name
      user.last_name = last_name
      user.email = email
      user.username = username unless username == email
      user.password!(password)

      puts "\n"

      if user.save
        puts "User has been created successfully! [ID: #{user.id}]"
      else
        puts "User could not be added for the following errors:"
        user.errors.full_messages.each { |m| puts "  - #{m}" }
      end
    end
  end
end

def banner(msg)
  puts "=========================================================================="
  puts "  #{msg}"
  puts "==========================================================================\n\n"
end

def ask_for_password
  password = ask('Password: ') { |q| q.echo = false }
  confirm = ask('Password again: ') { |q| q.echo = false }

  unless password.to_s.length > 4 and password == confirm
    puts "Password must be longer than 4 characters and match the confirmation."
    password = ask_for_password
  end

  password
end

def check_for_roles
  unless Role.table_exists? and Role.count > 0 and !!Role.admin
    unless admin
      puts "Oops, you need to run `rake challah:rolls:setup` before you run this step, the administrator role is required."
      exit 1
    end
  end
end

def check_for_tables
  unless ::User.table_exists?
    puts "Oops, you need to run `rake challah:setup` before you create a user. The users table is required."
    exit 1
  end
end