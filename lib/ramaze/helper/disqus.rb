require 'disqus'
require 'disqus/view_helpers'

module Ramaze
  module Helper
    ##
    # Provides shortcuts via Disqus::ViewHelpers.
    #
    # Make sure that you set your disqus credentials when using this helper:
    #   Disqus::defaults[:account] = "my_disqus_account"
    # And optionally, only if you're using the API
    #   Disqus::defaults[:api_key] = "my_disqus_api_key"
    #
    # Available methods are:
    #
    #   disqus_combo
    #   disqus_comment_counts
    #   disqus_popular_threads
    #   disqus_recent_comments
    #   disqus_thread
    #   disqus_top_commenters
    #
    module Disqus
      include ::Disqus::ViewHelpers
    end # Disqus
  end # Helper
end # Ramaze
