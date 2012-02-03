namespace :challah do
  namespace :roles do
    desc "Create a new role"
    task :create => :environment do
      check_for_tables
      check_for_roles

      banner('Creating a role')

      # Grab the required fields.    
      name = ask!('Name:')
      description = ask('Description [optional]:')
      path = ask('Default path [default: /]', '/')
      locked = ask('Lock this role [Yes/No, Default: No]', 'No')      
      
      locked = locked.to_s.downcase.strip.first == 'y'
      
      role = Role.new(:name => name, :description => description, :default_path => path, :locked => locked)

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
      first_name = ask!('First name:')
      last_name = ask!('Last name:')
      email = ask!('Email:')
      username = ask('Username [leave blank to use email address]:', email)
      password = ask('Password:')    

      role_id = Role.admin.id

      # First user is always going to be an admin, otherwise ask for the role
      unless first_user
        role = ask_for_role
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

def ask_for_role
  @role_names ||= Role.all.collect(&:name).sort.join('|')  
  role_name = ask!("Role Name: [#@role_names]")  
  role = Role.find_by_name(role_name)  
  return ask_for_role unless role  
  role
end

def ask!(question)
  ask(question, nil, false)
end

def ask(question, default = nil, allow_blank = true)
  print " -> #{question} "
  
  result = STDIN.gets.chomp
  
  if result.nil? or result.to_s.strip == ""
    if allow_blank
      return default
    else
      return ask(question, default, allow_blank)
    end
  else
    return result
  end
end