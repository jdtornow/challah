class User < ActiveRecord::Base

  # Set up Challah's User methods. Keep this as the first line of your model to include
  # all methods by default. You can override methods after this line as necessary.
  #
  # For a list of all methods included into User, see:
  #
  # http://rubydoc.info/gems/challah
  include Challah::Userable

end
