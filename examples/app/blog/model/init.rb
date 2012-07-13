# Configure Sequel. This example uses a SQLite3 database with it's encoding set
# to UTF-8. The :test option is used to confirm that the database connection is
# valid before it's actually being used. In this case the connection returned by
# Sequel.connect is stored in a constant called "DB" but you're free to store it
# wherever you want.
DB = Sequel.connect(
  :adapter  => 'sqlite',
  :database => __DIR__('../database.db'),
  :test     => true,
  :encoding => 'utf8'
)

# The validation_helpers plugin is required if you want to use the #validate()
# method in your model in combination with easy to use methods such as
# validates_presence().
Sequel::Model.plugin(:validation_helpers)

# The migration extension is needed in order to run migrations.
Sequel.extension(:migration)

# The pagination extension is needed by Ramaze::Helper::Paginate.
Sequel.extension(:pagination)

# Migrate the database
Sequel::Migrator.run(DB, __DIR__('../migrations'))

# Time to load all the models now that Sequel is set up.
require __DIR__('comment')
require __DIR__('post')
require __DIR__('user')

# Insert the default user if this hasn't already been done so.
unless User[:username => 'admin']
  User.create(:username => 'admin', :password => 'admin')
end

# Insert a default post if no posts have been added.
if Post.all.empty?
  Post.create(
    :title   => 'Example Post',
    :body    => 'This is a post that uses Markdown!',
    :user_id => User[:username => 'admin'].id
  )
end
