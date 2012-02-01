# Challah

Challah (pronounced HAH-lah) is a simple Rails authentication gem with user, role and permission controls baked in. Most of the functionality within the gem lives within a Rails engine and tries to stay out of the way of your app. 

## Requirements

* Ruby 1.8.7+
* Bundler
* RubyGems 1.8.12+
* Rails 3.1+

## Installation

Coming soon..

### Set Up

Once the gem has been set up and installed, run the following command to set up the database migrations:

    rake challah:setup
    
This will copy over the necessary migrations to your app, migrate the database and add some seeds. 

If you would prefer to handle these steps manually, you can do so by using these rake tasks instead:

    rake challah:setup:migrations
    rake db:migrate
    rake challah:setup:seeds

## Testing 

Challah is fully tested using Test::Unit, Shoulda and Mocha. To run the test suite, `bundle install` then run:

    rake test

## License

Challah is released under the [MIT license](http://www.opensource.org/licenses/MIT)