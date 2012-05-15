class User < ActiveRecord::Base
  # Set up Challah's User methods. Keep this as the first line of your model to include
  # all methods by default. You can override methods after this line as necessary.
  #
  # For a list of all methods included into User, see:
  #
  # http://rubydoc.info/gems/challah
  authable_user

  # Uncomment the following line to add additional attributes to protect using the
  # User#update_account_attributes(params) methods
  #
  # Note: This does not affect User#update_attributes
  #
  # protect_attributes :your_attributes, :here
end