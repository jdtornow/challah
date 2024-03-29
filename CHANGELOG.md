## Challah 2.0.0.beta2

* "Support" for Rails 7.0
* Drops support for Ruby prior to 2.6

## Challah 2.0.0.beta1

This version introduces the following breaking changes, and therefore a new major version number:

* Plugins no longer supported. This was never fully baked and was only used for the now defunct challah-rolls library, which is no longer maintained.
* Drops support for Rails 4
* Drops support for Ruby prior to 2.5.0
* Removes legacy support for boolean-based User#active column in favor of enums on User#status

Plus the following new changes:

* Support for Rails 6.0
* Authorizations table is now properly set as a foreign key to users (for new installations only, for existing tables you can do this yourself)

## Challah 1.6.1

* Prevent an email address that is blank from saving the `User#email_hash` attribute
* Removes default column for `last_session_ip` that unnecessarily stores user IP addresses by default and could be considered a privacy concern. This column can be manually included in the migration to still track the user IP.

## Challah 1.6.0

* For token technique, don't bother checking the database for an empty token query param
* Add migration generator to account for Rails 5 migration inheritance syntax (`ActiveRecord::Migration[5.1]`)
* Minor testing updates
* Dependency updates, including renaming FactoryGirl to FactoryBot
* Readme typo [PR #32](https://github.com/jdtornow/challah/pull/34) @stevenschobert

## Challah 1.5.0

* Extract status enum to separate concern [PR #32](https://github.com/jdtornow/challah/pull/32) @philtr
* Add built-in support for authenticating using X-Auth-Token header for APIs

## Challah 1.4.2

* Fix issue with duplicating models and audits [#28](https://github.com/jdtornow/challah/issues/28)

## Challah 1.4.1

* Fix running migrations on empty database [PR #27](https://github.com/jdtornow/challah/pull/27) @philtr

## Challah 1.4

* Rails 5 support.
* Changed `users.active` boolean column to `users.status` enum with `active` as one of the options.
* Update sign-in page default bootstrap styles

## Challah 1.3.3

* Fix Rails 4.2 "can't modify frozen hash ActiveSupport::HashWithIndifferentAccess" [PR #26](https://github.com/jdtornow/challah/pull/26) @stevenschobert

## Challah 1.3.2

* Relax importing of highline in rake tasks to only include when in use

## Challah 1.3.1

* Bug fix preventing SessionsController from loading

## Challah 1.3.0

* Compatibility with Rails5 (beta3)

## Challah 1.2.10/11

* Adds an `email` parameter for sign-in in addition to `username`. [PR #18](https://github.com/jdtornow/challah/pull/18) @thewatts

## Challah 1.2.9

* Adds support for apps that do not contain an `ApplicationController` in the main rails app. For example, if all of the app logic is contained within engines.

## Challah 1.2.8

* Localize invalid email message [PR #15](https://github.com/jdtornow/challah/pull/15) @thewatts

## Challah 1.2.7

* Gem updates [PR #14](https://github.com/jdtornow/challah/pull/14) @philtr

## Challah 1.2.6

* Normalize email address before writing to database [PR #13](https://github.com/jdtornow/challah/pull/13) @thewatts

## Challah 1.2.5

* Modified audit tracker for Rails 4.2 `ActiveRecord::AttributeSet`
* Added `timestamps null: true` to Authorizations table to remove deprecation warning

## Challah 1.2.4

* Modify `bcrypt` dependency [PR #10](https://github.com/jdtornow/challah/pull/10) @philtr

## Chalah 1.2.3

* Allow default techniques to be removed in the host app. [PR #9](https://github.com/jdtornow/challah/pull/9) @philtr

## Challah 1.2.2

* Bug fix for “A copy of User has been removed from the module tree but is still active!” error in Rails development mode. Fix was to not cache the `User` model reference from within the engine.

## Challah 1.2.1

* Bug fixed when loading `challah/test` in minitest.

## Challah 1.2.0

* Convert tests to RSpec
* Remove use of `challah_user` and `challah_authorization` and replace with concerns
* Internal clean up of included modules

## Challah 1.1.1

* Internal clean up of tests and gem dependencies
* Enable compatibility with Rails 4.1.0.rc1

## Challah 1.1.0

* Allow challah to authenticate with User and Authorization tables that using namespaces
* Multiple accounts can be signed in at once using multiple user tables

## Challah 1.0.0

* Ruby 2.0 compatibility
* Add option to disable built-in validations
* Rails 4.0.0 is the only supported Rails version

## Challah 0.9.1

* Basic compatibility with Rails 4. Removed support for `attr_accessible` in newer versions of Rails. Testing and a few other operations not yet support, but the gem is functional on Rails 4.

## Challah 0.9.0

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
