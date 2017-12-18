# Challah

[![Build Status](https://travis-ci.org/jdtornow/challah.svg?branch=master)](https://travis-ci.org/jdtornow/challah) [![Code Climate](https://codeclimate.com/github/jdtornow/challah/badges/gpa.svg)](https://codeclimate.com/github/jdtornow/challah) [![Dependency Status](https://gemnasium.com/jdtornow/challah.svg)](https://gemnasium.com/jdtornow/challah) [![Gem Version](https://badge.fury.io/rb/challah.svg)](https://badge.fury.io/rb/challah)

Challah (pronounced HAH-lah) is a simple Rails authentication gem that provides users a way to authenticate with your app. Most of the functionality within the gem lives within a Rails engine and tries to stay out of the way of your app.

Challah doesn't provide any fancy controllers or views that clutter your app or force you to display information a certain way. That part is up to you. The functionality within Challah is designed to be a starting point for users and sign-ins you can tweak the rest to your app's needs.

## Requirements

* Ruby 2.2.2+
* Bundler
* Rails 5.0+ (4.2 still supported, but not recommended)

## Installation

In your `Gemfile`

```ruby
gem "challah"
```

## Set up

Once the gem has been set up and installed, run the following command to set up the database migrations:

```bash
rails challah:setup
```

This will copy over the necessary migrations to your app and migrate the database. You will be prompted to add the first user as the last step in this process.

### Manual set up

If you would prefer to handle these steps manually, you can do so by using these rake tasks instead:

```bash
rails g challah
rails challah:unpack:user
rails db:migrate
```

### Creating users

Since Challah doesn't provide any controller and views for users there are a few handy rake tasks you can use to create new records.

Use the following task to create a new user:

```bash
# Creates a new User record
rails challah:users:create
```

## User Model

Challah provides the core `User` model for your app, and a database migration to go along with it. You can do anything you want with the model, just leave the `Challah::Userable` concern intact to keep Challah's standard user methods included.

A user is anyone that needs to be able to authenticate (sign in) to the application. Each user requires a first name, last name, email address, username, and password.

By default a user is marked as "active" and is able to log in to your application. If the active status column is toggled to `inactive`, then this user is no longer able to log in. The active status column can be used as a soft-delete function for users.

## Checking for a current user

The basic way to restrict functionality within your app is to require that someone authenticate (log in) before they can see it. From within your controllers and views you can call the `current_user?` method to determine if someone has authenticated. This method doesn't care about who the user is, or what it has access to, just that it has successfully authenticated and is a valid user.

For example, restrict the second list item to only users that have logged in:

```erb
<ul>
  <li><a href="/">Home</a></li>

  <% if current_user? %>
    <li><a href="/secret-stuff">Secret Stuff</a></li>
  <% end %>

  <li><a href="/public-stuff">Not-so-secret Stuff</a></li>
</ul>
```

Controllers can also be restricted using `before_action`:

```ruby
class WidgetsController < ApplicationController
  before_action :signin_required

  # ...
end
```

Or, you can call `restrict_to_authenticated` instead, which does the same thing:

```ruby
class WidgetsController < ApplicationController
  restrict_to_authenticated

  # ...
end
```

All normal Rails `before_action` options apply, so you can always limit this restriction to a specific action:


```ruby
class WidgetsController < ApplicationController
  restrict_to_authenticated only: [ :edit, :update, :destroy ]

  # ...
end
```

## Default Routes

By default, there are a few routes included with the Challah engine. These routes provide a basic method for a username and password sign in page. These routes are:

```text
GET   /sign-in      # => SessionsController#new
POST  /sign-in      # => SessionsController#create
GET   /sign-out     # => SessionsController#new
```

Feel free to override the `SessionsController` with something more appropriate for your app.

If you'd prefer to set up your own "sign in" and "sign out" actions, you can skip the inclusion of the default routes by adding the following line to an initializer file in your app:

```ruby
# in config/initializers/challah.rb
Challah.options[:skip_routes] = true
```

## Sign In Form

By default, the sign in form is tucked away within the Challah gem. If you'd like to customize the markup or functionality of the sign in form, you can unpack it into your app by running:

```bash
# Copy the sign in view into your app
rails challah:unpack:views
```

If necessary, the sessions controller which handles creating new sessions and signing users out can also be unpacked into your app. This is really only recommended if you need to add some custom behavior or have advanced needs.

```bash
# Copy the sessions controller into your app
rails challah:unpack:signin
```

## API Controllers

For apps that use JSON API controllers, Challah can be used to authenticate a user with a url parameter or an HTTP request header. This feature is disabled by default, so to use it you will need to change the `token_enabled` setting to `true`:

```ruby
# in config/initializers/challah.rb
Challah.options[:token_enabled] = true
```

Once enabled, this setting will allow the `api_key` for the user to be used to authenticate them via the `token` parameter, or `X-Auth-Token` HTTP header.

For example, the following request would authenticate a valid active user that has the `api_key` value of `abc123`:

``` shell
curl -H "X-Auth-Token: abc123" \
  -H 'Content-Type: application/json' \
  http://localhost:3000/api/test.json
```

Using the `token` param, you could write the same thing as:

``` shell
curl -H 'Content-Type: application/json' \
  http://localhost:3000/api/test.json?token=abc123
```

If you'd like to change the HTTP header used to fetch the user's api key from, you can change it using the `token_header` setting:

```ruby
# in config/initializers/challah.rb
Challah.options[:token_enabled] = true
Challah.options[:token_header] = "X-App-User"
```

Then:

``` shell
curl -H "X-App-User: abc123" \
  -H 'Content-Type: application/json' \
  http://localhost:3000/api/test.json
```

_Note: Custom HTTP headers should always start with X-_

## ActionCable in Rails 5

Challah works well with securing your ActionCable channels since Rails 5. Here is a sample `ApplicationCable::Connection` file to secure connections to a valid signed-in user:

```ruby
module ApplicationCable
  class Connection < ActionCable::Connection::Base

    identified_by :current_user

    def connect
      self.current_user = find_current_user
    end

    private

    def find_current_user
      if user = Challah::Session.find(request)
        user
      else
        reject_unauthorized_connection
      end
    end

  end
end
```

## Upgrading to Challah 1.4+

In Challah 1.4, the `active` boolean column changed to a `status` Rails enum with "active" as the default option. To upgrade a users table, use the following migration example:

```bash
rails g migration ConvertUsersActiveToEnum
```

```ruby
class ConvertUsersActiveToEnum < ActiveRecord::Migration
  def up
    add_column :users, :status, :integer, default: 0

    say_with_time "Converting users to status enum" do
      User.where(active: false).update_all(status: User.statuses[:inactive])
    end

    remove_column :users, :active
  end

  def down
    add_column :users, :active, :boolean, default: true

    say_with_time "Converting users to active boolean" do
      User.where(status: User.statuses[:inactive]).update_all(active: false)
    end

    remove_column :users, :status
  end
end
```

## User Validations

By default, the `first_name`, `last_name`, and `email` fields are required on the user model. If you'd prefer to add your own validations and leave the defaults off, you can use the following option within an initializer:

```ruby
# in config/initializers/challah.rb
Challah.options[:skip_user_validations] = true
```

## Authorization Model

The `Authorization` model can be used to store user credentials for a variety of different sources. By default, usernames and passwords are hashed and stored in this table.

In addition to the username/password, you can also use the authorizations table to store credentials or tokens for other services as well. For example, you could store a successful Facebook session using the following method:

```ruby
Authorization.set({
  # provider is just a key and can be anything to denote this service
  provider: :facebook,

  # the user's Facebook UID
  uid: "000000",

  # the user's Facebook-provided access token
  token: "abc123",

  # the user ID to link to this authorization
  user_id: user.id,

  # (optional, when this token expires)
  expires_at: 60.minutes.from_now
})
```

Then, to remove an authorization, just provide the user'd ID and the provider:

```ruby
Authorization.del({
  provider: :facebook,
  user_id: user.id
})
```

## Full documentation

Documentation is available at: [http://rubydoc.info/gems/challah](http://rubydoc.info/gems/challah)

## Issues

If you have any issues or find bugs running Challah, please [report them on Github](https://github.com/jdtornow/challah/issues). While most functions should be stable, Challah is still in its infancy and certain issues may be present.

## Testing

Challah is fully tested using RSpec. To run the test suite, `bundle install` then run:

```bash
rspec
```

## License

Challah is released under the [MIT license](http://www.opensource.org/licenses/MIT)

Contributions and pull-requests are more than welcome.
