module Ramaze
  module Helper
    ##
    # The SendFile module can be used to stream a file to the user's computer.
    # While the performance of the module isn't optimal it's convenient and
    # relatively easy to use.
    #
    module SendFile
      ##
      # The send_file method streams the specified file to the user's browser.
      #
      # @param [String] filename The name or path to the file which will be 
      #  streamed to the user.
      # @param [String] content_type The type of file we're dealing with. For
      #  example, if we want to stream a JPG image we'd set this variable to
      #  'image/jpg'.
      # @param [String] content_disposition Value for the Content-Disposition 
      #  header.
      #
      def send_file(filename, content_type = nil, content_disposition = nil)
        content_type ||= Rack::Mime.mime_type(::File.extname(filename))
        content_disposition ||= File.basename(filename)

        response.body = ::File.open(filename, 'rb')
        response['Content-Length'] = ::File.size(filename).to_s
        response['Content-Type'] = content_type
        response['Content-Disposition'] = content_disposition
        response.status = 200

        throw(:respond, response)
      end
    end # SendFile
  end # Helper
end # Ramaze
