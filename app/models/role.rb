class Role < ActiveRecord::Base
  # Set up Challah's Role methods. Keep this as the first line of your model to include
  # all methods by default. You can override methods after this line as necessary.
  #
  # For a list of all methods included into Role, see:
  #
  # http://rubydoc.info/gems/challah
  authable_role
end