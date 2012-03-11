# Challah

[![Build Status](https://secure.travis-ci.org/jdtornow/challah.png)](http://travis-ci.org/jdtornow/challah) [![Dependency Status](https://gemnasium.com/jdtornow/challah.png?travis)](https://gemnasium.com/jdtornow/challah)

Challah (pronounced HAH-lah) is a simple Rails authentication gem with user, role and permission controls baked in. Most of the functionality within the gem lives within a Rails engine and tries to stay out of the way of your app.

Challah doesn't provide any fancy controllers or views that clutter your app or force you to display information a certain way. That part is up to you. The functionality within Challah is designed to be a starting point for users, roles, and permissions and you can tweak the rest to your app's needs.

## Requirements

* Ruby 1.8.7, 1.9.2 or 1.9.3
* Bundler
* Rails 3.1+

## Installation

    gem install challah

Or, in your `Gemfile`

    gem 'challah'

## Set up

Once the gem has been set up and installed, run the following command to set up the database migrations:

    rake challah:setup
    
This will copy over the necessary migrations to your app, migrate the database and add some seed data. You will be prompted to add the first user as the last step in this process. 

### Manual set up

If you would prefer to handle these steps manually, you can do so by using these rake tasks instead:

    rake challah:setup:migrations
    rake db:migrate
    rake challah:setup:seeds
    rake challah:users:create
    
### Creating users, permissions and roles

Since Challah doesn't provide any controller and views for users, permissions and roles there are a few handy rake tasks you can use to create new records.

The following tasks will prompt for the various attributes in each model:

    rake challah:permissions:create     # => Create a new Permission record
    rake challah:roles:create           # => Create a new Role record
    rake challah:users:create           # => Creates a new User record
    
## Models

Challah provides three core models to your app: Permission, Role and User. By default, these models are hidden away in the Challah gem engine, but you can always copy the models into your app to make further modifications to the functionality. 

### User

A user is anyone that needs to be able to authenticate (log in) to the application. Each user requires a first name, last name, email address, username, role and password.

By default a user is marked as "active" and is able to log in to your application. If the active status column is toggled to false, then this user is no longer able to log in. The active status column can be used as a soft-delete function for users.

Each user is assigned to exactly one `Role` and can also be assigned to multiple `Permission` objects as needed. Because a user can be assigned to a role (and therefore its permissions) *and* permissions on an ad-hoc basis, it is important to always check a user record for restrictions based on permissions and not to use roles as a mechanism for restricting functionality in your app.

### Permission

A permission is used to identify something within your application that you would like to restrict to certain users. A permission does not inherently have any functionality of its own and is just used as a reference point for pieces of functionality in your app. A permission record requires the presence of a name and key.

A permission's key is used throughout Challah to refer to this permission. Each key (and name) must be unique and will be used later to restrict access to functionality. Permission keys must be lowercase and contain only letters, numbers, and underscores.

If there is a role named 'Administrator' in your app, all permissions will be available to that role. Any new permissions that are added will also be automatically added to the 'Administrator' role, so this is a great role to use for anyone that needs to be able to do everything within your app.

The default Challah installation creates two permissions by default: `admin` and `manage_users`.

### Role

A role is used to group together various permissions and assign them to a user. Roles can also be thought of as user groups. Each role record requires a unique name. 

Roles should only be used within your app to consolidate various permissions into logical groups. Roles are not intended to be used to restrict functionality, use permissions instead. 

The default Challah installation creates two roles by default: 'Administrator' and 'Default'. Administrators have all permissions, now and in the future. Default users have no permissions other than being able to log in.

Once you've added a few other permissions, you can easily add them to a role. In this case, the `moderator` permission key is added to the default role:

    role = Role[:default]
    role.permission_keys = %w( moderator )
    role.save

## Restricted access

One of the main reasons to use a user- and permission-based system is to restrict access to certain portions of your application. Challah provides basic restriction methods for your controllers, views and directly from any User instance.

### Checking for a current user

The basic way to restrict functionality within your app is to require that someone authenticate (log in) before they can see it. From within your controllers and views you can call the `current_user?` method to determine if someone has authenticated. This method doesn't care about who the user is, or what it has access to, just that it has successfully authenticated and is a valid user.

For example, restrict the second list item to only users that have logged in:

    <ul>
      <li><a href="/">Home</a></li>

      <% if current_user? %>
        <li><a href="/secret-stuff">Secret Stuff</a></li>
      <% end %>

      <li><a href="/public-stuff">Not-so-secret Stuff</a></li>
    </ul>

Controllers can also be restricted using `before_filter`: 

    class WidgetsController < ApplicationController
      before_filter :login_required

      # …	
    end

Or, you can call `restrict_to_authenticated` instead, which does the same thing:

    class WidgetsController < ApplicationController
      restrict_to_authenticated

      # ...	
    end

All normal Rails `before_filter` options apply, so you can always limit this restriction to a specific action:

    class WidgetsController < ApplicationController
      restrict_to_authenticated :only => [ :edit, :update, :destroy ]

      # ...	
    end

### Checking for a permission

Since Challah is a permissions-based system, all restricted access should be performed by testing a user for the given permission. 

Anywhere you can access a user instance, you can use the `has` method and pass in a single permission key to test that user for access:

    <ul>
      <li><a href="/">Home</a></li>

      <% if current_user? and current_user.has(:secret_stuff) %>
        <li><a href="/secret-stuff">Secret Stuff</a></li>
      <% end %>

      <li><a href="/public-stuff">Not-so-secret Stuff</a></li>
    </ul>

Notice that we checked for existance of the user before we checked to see if the user has a permission. If you used the `restrict_to_authenticated` method in your controller, you can likely skip this step. 

Note: `current_user` will return `nil` if there is no user available, so checking for `current_user?` prevents you from calling `has` on `nil`.

For controller restrictions, use the `restrict_to_permission` method:

    class WidgetsController < ApplicationController
      restrict_to_permission :manage_widgets

      # ...	
    end

The `restrict_to_permission` method will also fail if there is no user currently authenticated.

And, just as before, we can use the Rails filter options to limit the restriction to certain actions.

    class WidgetsController < ApplicationController
      restrict_to_permission :admin, :only => [ :destroy ]

      # ...	
    end

And of course, you can stack up multiple restrictions get very specific about what your users can do:

    # Everyone can view index,
    # :manage_widgets users can perform basic editing
    # and, only :admins can delete
    #
    class WidgetsController < ApplicationController
      restrict_to_authenticated :only => [ :index ]
      restrict_to_permission :manage_widgets, :except => [ :index, :destroy ]
      restrict_to_permission :admin, :only => [ :destroy ]

      # ...	
    end

Whichever method you use will yield the same results. Just make sure you are checking for a permission key, and not checking for a role. Checking for roles (i.e.: `user.role_id == 1`) is shameful practice. Use permissions!

## Default Routes

By default, there are a few routes included with the Challah engine. These routes provide a basic method for a username- and password-based login page. These routes are:

    GET   /login        # => SessionsController#new
    POST  /login        # => SessionsController#create
    GET   /logout       # => SessionsController#new
    
Feel free to override the `SessionsController` with something more appropriate for your app.

If you'd prefer to set up your own login/logout actions, you can skip the inclusion of the default routes by adding the following line to an initializer file in your app:

    Challah.options[:skip_routes] = true

## Full documentation

Documentation is available at: [http://rubydoc.info/gems/challah](http://rubydoc.info/gems/challah/frames)

### Issues

If you have any issues or find bugs running Challah, please [report them on Github](https://github.com/jdtornow/challah/issues). While most functions should be stable, Challah is still in its infancy and certain issues may be present.

### Testing

Challah is fully tested using Test Unit, Shoulda and Mocha. To run the test suite, `bundle install` then run:

    rake test

## License

Challah is released under the [MIT license](http://www.opensource.org/licenses/MIT)

Contributions and pull-requests are more than welcome.
