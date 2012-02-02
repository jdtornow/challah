namespace :challah do
  desc "Create a new user"
  task :createuser => :environment do
    puts "Please answer the following questions to create your first admin user." if User.count == 0
    
    first_name = ask('First name:')
  end
end

def ask(question, default = nil, allow_blank = true)
  print "#{question} "
  
  result = STDIN.gets.chomp
  
  if result.nil? or result.to_s.strip == ""
    if allow_blank
      return default
    else
      return ask(*args)
    end
  else
    return result
  end
end