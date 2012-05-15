class Permission < ActiveRecord::Base
  # Set up Challah's Permission methods. Keep this as the first line of your model to include
  # all methods by default. You can override methods after this line as necessary.
  #
  # For a list of all methods included into Permission, see:
  #
  # http://rubydoc.info/gems/challah
  authable_permission
end