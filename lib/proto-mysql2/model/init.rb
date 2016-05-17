# Open the database
require 'ramaze'
require 'mysql2'
require 'sequel'
require 'yaml'

# open up the appropriate database and log it
Host = YAML.load_file("#{Ramaze.options.roots[0]}/database.yml")[ENV['MODE']]
DB = Sequel.connect(Host)
Ramaze::Log.info "Database \"#{Host['database']}\" opened"

# Require all models in the models folder
Dir.glob('model/*.rb').each do |model|
  require("#{Ramaze.options.roots[0]}/#{model}")
end
