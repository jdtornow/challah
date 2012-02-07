require 'highline/import'

namespace :challah do 
  namespace :permissions do
    desc "Create a new permission"
    task :create => :environment do
      check_for_tables
      check_for_roles

      banner('Creating a permission')

      # Grab the required fields.      
      name = ask('Permission name: ')
      key = name.to_s.parameterize.underscore
      key = ask('Key: ') { |q| q.default = key }      
      description = ask('Description (optional): ')
      
      permission = Permission.new(:name => name, :key => key, :description => description)

      puts "\n"

      if permission.save
        puts "Role has been created successfully! [ID: #{permission.id}]"
      else
        puts "Role could not be added for the following errors:"
        permission.errors.full_messages.each { |m| puts "  - #{m}" }
      end
    end
  end
  
  namespace :roles do
    desc "Create a new role"
    task :create => :environment do
      check_for_tables
      check_for_roles

      banner('Creating a role')

      # Grab the required fields.    
      name = ask('Name: ')
      description = ask('Description (optional): ')
      
      role = Role.new(:name => name, :description => description)

      puts "\n"

      if role.save
        puts "Role has been created successfully! [ID: #{role.id}]"
      else
        puts "Role could not be added for the following errors:"
        role.errors.full_messages.each { |m| puts "  - #{m}" }
      end
    end
  end
  
  namespace :users do
    desc "Create a new user"
    task :create => :environment do
      check_for_tables
      check_for_roles

      first_user = User.count == 0

      banner('Creating a user')

      if first_user
        puts "Please answer the following questions to create your first admin user.\n\n"
      end    

      # Grab the required fields.    
      first_name = ask('First name: ')
      last_name = ask('Last name: ')
      email = ask('Email: ')
      username = ask('Username: ') { |q| q.default = email }
      password = ask('Password: ') { |q| q.echo = false }
      confirm = ask('Password again: ') { |q| q.echo = false }

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

      user = User.new(:first_name => first_name, :last_name => last_name, :email => email, :username => username, :role_id => role_id, :password => password, :password_confirmation => password)

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

def check_for_roles
  unless Role.table_exists? and Role.count > 0 and !!Role.admin
    unless admin
      puts "Oops, you need to run `rake challah:setup` before you run this step, the administrator role is required."
      exit 1
    end
  end
end

def check_for_tables
  unless User.table_exists?
    puts "Oops, you need to run `rake challah:setup` before you create a user. The users table is required."
    exit 1
  end
end