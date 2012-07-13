#          Copyright (c) 2009 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the MIT license.

module Ramaze
  module Helper
    ##
    # The Auth helper can be used for authentication without using a model.
    # This can be useful when working with very basic applications that don't
    # require database access.
    #
    # If you're looking for a way to do authentication using a model you should
    # take a look at Helper::User instead.
    #
    module Auth
      Helper::LOOKUP << self
      include Ramaze::Traited

      trait :auth_table     => {}
      trait :auth_hashify   => lambda { |pass| Digest::SHA1.hexdigest(pass) }
      trait :auth_post_only => false

      def self.included(into)
        into.helper(:stack)
      end

      ##
      # Log a user in based on the :username and :password key in the request
      # hash.
      #
      # @return [String] The login template in case the user's login data was
      #  incorrect.
      #
      def login
        if trait[:auth_post_only] and !request.post?
          return auth_template
        end

        @username, password = request[:username, :password]

        answer(request.referer) if auth_login(@username, password)

        return auth_template
      end

      ##
      # Log the user out and redirect him back to the previous page.
      #
      def logout
        auth_logout
        redirect_referrer
      end

      private

      ##
      # Validate the user's session and redirect him/her to the login page in
      # case the user isn't logged in.
      #
      def login_required
        call(r(:login)) unless logged_in?
      end

      ##
      # Validate the user's session and return a boolean that indicates if the
      # user is logged in or not.
      #
      # @return [true false] Whether user is logged in right now
      #
      def logged_in?
        !!session[:logged_in]
      end

      ##
      # Try to log the user in based on the username and password.
      # This method is called by the login() method and shouldn't be called
      # directly.
      #
      # @param [String] user The users's username.
      # @param [String] pass The user's password.
      #
      def auth_login(user, pass)
        return unless user and pass
        return if user.empty? or pass.empty?

        return unless table   = ancestral_trait[:auth_table]
        return unless hashify = ancestral_trait[:auth_hashify]

        if table.respond_to?(:to_sym) or table.respond_to?(:to_str)
          table = send(table)
        elsif table.respond_to?(:call)
          table = table.call
        end

        return unless table[user] == hashify.call(pass)

        session[:logged_in] = true
        session[:username]  = user
      end

      ##
      # Remove the session items that specified that the user was logged in.
      #
      def auth_logout
        session.delete(:logged_in)
        session.delete(:username)
      end

      ##
      # Method that returns a small form that can be used for logging in.
      #
      # @return [String] The login form.
      def auth_template
        <<-TEMPLATE.strip!
<form method="post" action="#{r(:login)}">
  <ul style="list-style:none;">
    <li>Username: <input type="text" name="username" value="#@username"/></li>
    <li>Password: <input type="password" name="password" /></li>
    <li><input type="submit" /></li>
  </ul>
</form>
        TEMPLATE
      end
    end # Auth
  end # Helper
end # Ramaze
