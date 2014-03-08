class User < ActiveRecord::Base
  # Uncomment this line if you are not using Rails 4. If you'd like to continue using
  # attr_accessible you can always install the strong_parameters gem from:
  # https://github.com/rails/strong_parameters
  #
  # attr_accessible :email, :first_name, :last_name, :password_confirmation, :password, :username

  # Set up Challah's User methods. Keep this as the first line of your model to include
  # all methods by default. You can override methods after this line as necessary.
  #
  # For a list of all methods included into User, see:
  #
  # http://rubydoc.info/gems/challah
  include Challah::Userable
end
