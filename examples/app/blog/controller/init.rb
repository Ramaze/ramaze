##
# Base controller that provides a few things used by sub controllers throughout
# this example application.
#
# @since  26-09-2011
#
class BaseController < Ramaze::Controller
  engine :etanni
  layout :default
  helper :blue_form, :user, :xhtml, :paginate

  # Configures the Paginate helper so that it shows a maximum of 10 posts per
  # page and uses the "page" query string key to determine the current page.
  # This will result in URLs such as /posts?page=2. Note that when calling the
  # paginate() method you can override these settings.
  trait :paginate => {
    :var   => 'page',
    :limit => 10
  }

  # Tells the User helper what model class should be used for the authenticate()
  # method. By default this is already set to "User" so technically this isn't
  # required but to make it easier to understand what's going on I decided to
  # put it here.
  trait :user_model => User
end

# Load all other controllers
require __DIR__('posts')
require __DIR__('users')
