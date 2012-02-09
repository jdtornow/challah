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