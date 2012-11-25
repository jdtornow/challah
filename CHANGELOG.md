## Challah 0.9.0 (Unreleased)

* Removed some legacy support for default login paths
* Added authorizations table support. Shifting to flexible model for providers instead of always relying on username and password support.
* Users no longer require usernames and passwords for creation.

## Challah 0.8.3

* Various internal cleanup and preparations for future flexabilty
* Added `Authenticators` classes to ease transition for other authentication methods in the future
* Added `Validators` classes to allow for more fine-tuned control over email and password validation. Note: Email addresses are now validated to look like emails. Override `Challah.options[:email_validator]` to use a different `ActiveModel::EachValidator` for specific needs.
* Removed `User.search()` method. Leaving this detail up to the app instead of hiding it in a gem.

## Challah 0.8.2

* Removing default_scope from user model.

## Challah 0.8.1

* Use an unscoped finder to reduce load time looking for the current session.

## Challah 0.8.0

* Enabled plugin abilties with `Challah.register_plugin`. This restores the ability to use permissions and roles through the [challah-rolls gem](https://github.com/jdtornow/challah-rolls).

## Challah 0.7.1

* Ensure users can be looked up by username as case insensitive value. Allows logins posted from iOS devices (with initial caps) to be valid usernames even when stored as caps.

## Challah 0.7.0

* Removed roles and permissions functionality to keep the gem completely geared towards user authentication. In a future release this functionality will be added back into its own separate gem.
* User model is automatically unpacked into the app upon install

## Challah 0.6.2

* Gem dependency updates
* Don't increase session counter for non-persisted sessions. This is helpful for designing API requests that don't need a session count after each request.
* Added `email_hash` column to users table. After a user record is saved the email address is hashed for use with services like Gravatar.com. Existing user tables without the `email_hash` column will not be affected.

## Challah 0.6.1

* Bug fix, `signed_in?` should be included in helper methods.

## Challah 0.6.0

* Gem dependency updates
* Reduced application load time by eager loading ActiveRecord and ActionController modules once they are loading instead of on gem load.
* Lots of cleanup
* Added scoped User finders for `find_all_by_role` and `find_all_by_permission`
* Added routes for "/sign-in" and "/sign-out" in addition to "/login" and "/logout"
* Sign in form by default is styled using Twitter Bootstrap compatible markup. Override `views/sessions/new.html.erb` with your own view to modify the markup.
* Added various rake tasks for unpacking the internals of the gem into an app. (run `rake -T challah:unpack` to see details)

## Challah 0.5.4

* Bug fixes for Rails v3.2.3 mass assignment defaults.

## Challah 0.5.3

* Updated tests to conform with Factory Girl 3.0
* Added `login_as` and `logout` test helper methods into `ActiveSupport::TestCase` by default. These methods can be used within functional tests to authenticate a user for a given test.
* For each test run, all test sessions are cleared.
* Removing support for Ruby 1.8.7, since Factory Girl does not support it anymore.

## Challah 0.5.2

* Created `SimpleCookieStore` and use it as the default storage method for Session. This varies from `CookieStore` only because the user agent and remote IP address are not used in the cookie.

## Challah 0.5.1

* Dependency updates for Shoulda 3.0 and Rails 3.2.2.
* Added multiple Gemfile configurations for Travis CI.

## Challah 0.5.0

* Modified user permission key lookup to use caching of permission keys.
* Added timestamps to roles migration.

## Challah 0.4.1

* Added User#protect_attributes to allow for the addition of app-specific protected attributes in User

## Challah 0.4.0

* Enabled api key access. Passing ?key=xxxx into any URL will authenticate a user for a single page load. This option is turned off by default in new apps and can be enabled using `Challah.options[:api_key_enabled]`.
* Updated tests for API key access
* Authenticate users on page load
* Changed default api key length to 50 instead of 25

## Challah 0.3.5

* Now using [Highline](https://github.com/JEG2/highline) for rake tasks instead of sloppy custom methods.

## Challah 0.3.4

* Added `challah/test` include to allow for testing in your app.

## Challah 0.3.3

* Added User#valid_session? method to check to see if this user is valid on each page load.

## Challah 0.3.2

* Moving translations to accommodate for new namespace.

## Challah 0.3.1

* Removed name spacing of controllers and default routes.
* Added option to not include default routes

## Challah 0.3.0

* Documentation clean up.
* Added rake tasks for creating role, permission and user records.

## Challah 0.2.0

* Initial build. Basic functionality for session persistence and authentication.