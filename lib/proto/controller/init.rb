# Define a subclass of Ramaze::Controller holding your defaults for all controllers. Note 
# that these changes can be overwritten in sub controllers by simply calling the method 
# but with a different value.

class Controller < Ramaze::Controller
  layout :default
  helper :xhtml
  engine :etanni
end

# Require all controllers in the controllers folder
Dir.glob('controller/*.rb').each do |controller|
  require("#{Ramaze.options.roots[0]}/#{controller}")
end
