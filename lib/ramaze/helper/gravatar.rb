module Ramaze
  module Helper
    # Helps you building Gravatar URIs from an email address.
    #
    # For more information about gravatars, please see: http://gravatar.com
    #
    # The implementation of the gravatar method changed significantly, it does
    # less hand-holding but is more flexible so you can simply put your own
    # helper on top.
    #
    # It might not know about all the secret parameters (like 'force'), if you
    # find out more of these please consider contributing a patch.
    module Gravatar
      # API to build gravatar URIs from an email address (or any other String).
      #
      # @example Simple usage
      #   class Gravatars < Ramaze::Controller
      #     helper :gravatar
      #
      #     def index
      #       %q(
      #       Input your email address and I'll show you your Gravatar
      #       <form>
      #         <input type="text" name="email" />
      #         <input type="submit" />
      #       </form>
      #       <?r if email = request[:email] ?>
      #         Your gravatar is:
      #         <img src="#{gravatar(email)}" />
      #       <?r end ?>
      #       )
      #     end
      #   end
      #
      # @option opts [#to_s] :ext (nil)
      #   append a filename extension for the image, like '.jpg'
      #
      # @option opts [#to_i] :size (80)
      #   The size of the gravatar, square, so 80 is 80x80.
      #   Allowed range is from 1 to 512.
      #
      # @option opts [#to_s] :rating ('g')
      #   Only serve a gravatar if it has a content rating equal or below the
      #   one specified. Ratings, in order are: 'g', 'pg', 'r', or 'x'
      #
      # @option opts [#to_s] :default (nil)
      #   Fall back to default if the given +email+ doesn't have an gravatar;
      #   may be an absolute url, 'identicon', 'monsterid', or 'wavatar'
      #
      # @option opts [true, false] :force (false)
      #   Force use of the default avatar, useful if you want to use only
      #   identicons or the like
      #
      # @param [#to_str] email
      # @return [URI]
      # @see http://en.gravatar.com/site/implement/url
      # @author manveru
      #
      def gravatar(email, opts = {})
        uri = URI("http://www.gravatar.com/")
        ext = opts[:ext]
        uri.path = "/avatar/#{Digest::MD5.hexdigest(email.to_str)}#{ext}"

        query = {}
        query[:size]    = opts[:size].to_i.to_s if opts.key?(:size)
        query[:rating]  = opts[:rating].to_s if opts.key?(:rating)
        query[:default] = opts[:default].to_s if opts.key?(:default)
        query[:force]   = '1' if opts[:force]

        uri.query = Rack::Utils.build_query(query) if query.any?
        uri
      end
    end # Gravatar
  end # Helper
end # Ramaze
