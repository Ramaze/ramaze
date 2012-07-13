module Ramaze
  module Helper
    ##
    # This helper provides a convenience wrapper for handling authentication
    # and persistence of users.
    #
    # On every request, when you use the {UserHelper#user} method for the first
    # time, we confirm the authentication and store the returned object in the
    # request.env, usually this will involve a request to your database.
    #
    # @example Basic usage with User::authenticate
    #   # We assume that User::[] will make a query and returns the requested
    #   # User instance. This instance will be wrapped and cached.
    #
    #   class User
    #     def self.authenticate(creds)
    #       User[:name => creds['name'], :pass => creds['pass']]
    #     end
    #   end
    #
    #   class Profiles < Ramaze::Controller
    #     helper :user
    #
    #     def edit
    #       redirect_referrer unless logged_in?
    #       "Your profile is shown, your are logged in."
    #     end
    #   end
    #
    #   class Accounts < Ramaze::Controller
    #     helper :user
    #
    #     def login
    #       return unless request.post?
    #       user_login(request.subset(:name, :pass))
    #       redirect Profiles.r(:edit)
    #     end
    #
    #     def logout
    #       user_logout
    #       redirect_referer
    #     end
    #   end
    #
    # On every request it checks authentication again and retrieves the model,
    # we are not using a normal cache for this as it may lead to behaviour that
    # is very hard to predict and debug.
    #
    # You can however, add your own caching quite easily.
    #
    # @example caching the authentication lookup with memcached
    #   # Add the name of the cache you are going to use for the authentication
    #   # and set all caches to use memcached
    #
    #   Ramaze::Cache.options do |cache|
    #     cache.names = [:session, :user]
    #     cache.default = Ramaze::Cache::MemCache
    #   end
    #
    #   class User
    #
    #     # Try to fetch the user from the cache, if that fails make a query.
    #     # We are using a ttl (time to live) of one hour, that's just to show
    #     # you how to do it and not necessary.
    #     def self.authenticate(credentials)
    #       cache = Ramaze::Cache.user
    #
    #       if user = cache[credentials]
    #         return user
    #       elsif user = User[:name => creds['name'], :pass => creds['pass']]
    #         cache.store(credentials, user, :ttl => 3600)
    #       end
    #     end
    #   end
    #
    # @example Using a lambda instead of User::authenticate
    #   # assumes all your controllers inherit from this one
    #
    #   class Controller < Ramaze::Controller
    #     trait :user_callback => lambda{|creds|
    #       User[:name => creds['name'], :pass => creds['pass']]
    #     }
    #   end
    #
    # @example Using a different model instead of User
    #   # assumes all your controllers inherit from this one
    #
    #   class Controller < Ramaze::Controller
    #     trait :user_model => Account
    #   end
    #
    # @author manveru
    #
    module UserHelper
      # Using this as key in request.env
      RAMAZE_HELPER_USER = 'ramaze.helper.user'.freeze

      ##
      # Use this method in your application, but do not use it in conditionals
      # as it will never be nil or false.
      #
      # @api    external
      # @author manveru
      # @return [Ramaze::Helper::User::Wrapper] wrapped return value from
      #  model or callback
      #
      def user
        env = request.env
        found = env[RAMAZE_HELPER_USER]
        return found if found

        model, callback = ancestral_trait.values_at(:user_model, :user_callback)
        model ||= ::User unless callback
        env[RAMAZE_HELPER_USER] = Wrapper.new(model, callback)
      end

      ##
      # This method is used to authenticate a user against the supplied
      # credentials (which default to ``request.params``).
      #
      # This method is a proxy to  user._login which returns the value as
      # returned by ``Ramaze::Helper::User::Wrapper#_login``.
      #
      # The supplied argument should be a hash with the user's credentials.  The
      # credentials hash may use any naming for the hash keys as long as they
      # are consistent with the model which authenticates them (through the
      # ``authenticate()`` method) such as:
      #
      #     {"username" =>"name", "password" => "the_passwd"}
      #
      # On success it returns a hash of the credentials embedded within a hash
      # whose only key is ':credentials' such as the following:
      #
      #     {:credentials=>{"username"=>"myuser", "password"=>"mypassword"}}
      #
      # On failure to authenticate this method returns nil.
      #
      # @example
      #  auth = {"username" => "my_username", "password" => "mypass"}
      #  creds = user_login(auth)
      #  if creds
      #    respond 'You have been logged in as #{creds[:credentials]["username"]}', 200
      #  else
      #    respond 'You could not be logged in', 401
      #  end
      #
      # @author manveru
      # @api    external
      # @see    Ramaze::Helper::User::Wrapper#_login
      # @param  [Hash] creds the credentials that will be passed to the callback or model.
      # @return [nil Hash[Hash]]
      #
      def user_login(creds = request.params)
        user._login(creds)
      end

      ##
      # Shortcut for user._logout
      #
      # @author manveru
      # @api    external
      # @see    Ramaze::Helper::User::Wrapper#_logout
      # @return [NilClass]
      #
      def user_logout
        user._logout
      end

      ##
      # Checks if the user is logged in and returns true if this is the case and
      # false otherwise.
      #
      # @author manveru
      # @api    external
      # @see    Ramaze::Helper::User::Wrapper#_logged_in?
      # @return [TrueClass|FalseClass] whether the user is logged in already.
      #
      def logged_in?
        user._logged_in?
      end

      ##
      # Wrapper for the ever-present "user" in your application. It wraps
      # around an arbitrary instance and worries about authentication and
      # storing information about the user in the session.
      #
      # In order to not interfere with the wrapped instance/model we start our
      # methods with an underscore.
      #
      # Patches and suggestions are highly appreciated.
      #
      class Wrapper < BlankSlate
        attr_accessor :_model, :_callback, :_user

        def initialize(model, callback)
          @_model, @_callback = model, callback
          @_user = nil
          _login
        end

        ##
        # @author manveru
        # @see    Ramaze::Helper::User#user_login
        # @param  [Hash] creds this hash will be stored in the session on
        #  successful login
        # @return [Ramaze::Helper::User::Wrapper] wrapped return value from
        #  model or callback
        #
        def _login(creds = nil)
          if creds
            if @_user = _would_login?(creds)
              Current.session.resid!
              self._persistence = {:credentials => creds}
            end
          elsif persistence = self._persistence
            @_user = _would_login?(persistence[:credentials])
          end
        end

        ##
        # The callback should return an instance of the user, otherwise it
        # should answer with nil.
        #
        # This will not actually login, just check whether the credentials
        # would result in a user.
        #
        def _would_login?(creds)
          return unless creds

          if c = @_callback
            c.call(creds)
          elsif _model.respond_to?(:authenticate)
            _model.authenticate(creds)
          else
            Log.warn(
              "Helper::User has no callback and there is no %p::authenticate" \
                % _model
            )

            nil
          end
        end

        ##
        # @author manveru
        # @api    internal
        # @see    Ramaze::Helper::User#user_logout
        #
        def _logout
          (_persistence || {}).clear
          Current.request.env['ramaze.helper.user'] = nil
          Current.session.resid!
        end

        ##
        # @author manveru
        # @api    internal
        # @see    Ramaze::Helper::User#logged_in?
        # @return [true false] whether the current user is logged in.
        #
        def _logged_in?
          !!_user
        end

        def _persistence=(obj)
          Current.session[:USER] = obj
        end

        def _persistence
          Current.session[:USER]
        end

        ##
        # Refer everything not known
        # THINK: This might be quite confusing... should we raise instead?
        #
        def method_missing(meth, *args, &block)
          return unless _user
          _user.send(meth, *args, &block)
        end
      end
    end # User
  end # Helper
end # Ramaze
