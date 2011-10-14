# Models

Unlike other frameworks Ramaze does not ship with a database toolkit. One of the
ideas of Ramaze is that it allows you to choose your own set of tools, you're
not forced to use what we think is best. Ramaze allows you to use
[ActiveRecord][ar], [Sequel][sequel] or anything else. For the simplicity of
this user guide we'll use Sequel. In short, Sequel is a database toolkit that
allows you to write SQL statements using Ruby methods as well as providing an
ORM (Object Relationship Mapper).

Let's say we're creating a simple blog application. Each blog has posts,
comments, users and perhaps some categories. We're not going to create a model
for each of these entities in this guide but instead we'll focus on the Post
model. The most basic form of a model looks like the following:

    class Post < Sequel::Model

    end

From this point on we can load our model (given we have established a database
connection) and call methods from it. For example, if we want to retrieve the
post with ID #1 we'd do the following:

    Post[1] # => SELECT * FROM posts WHERE id = 1

Performing a WHERE clause and retrieving a single record can be done by passing
a hash to the [] method:

    Post[:title => 'Ramaze is Great'] # => SELECT * FROM posts WHERE title = 'Ramaze is Great'

## Controllers And Models

Of course using a model on its own isn't really going to work. Let's combine
our Post model mentioned earlier with a controller called "Posts".

    require 'ramaze'
    require 'model/post'

    class Posts < Ramaze::Controller
      map '/'

      def index
        @posts = Post.all
      end

      def edit(id)
        # Arguments are passed as strings so it's a good idea to convert them
        @post = Post[id.to_i]
      end
    end

This is a somewhat more advanced example of how to use controllers and models.
However, it's nothing ground breaking and shouldn't be too hard to understand.
In the index() method we're simply retrieving all posts by calling Post#all and
storing them in an instance variable. In the edit() method we're retrieving the
post based on the given ID.

In the edit() method the "id" variable is also converted to an integer. The
reason for this is that Ramaze doesn't know what types the URI segments should
be and thus passes them as a string to the called method. While Sequel itself
won't have any trouble handling this it's a good practice to send the correct
types as other database toolkits might trigger errors when they receive a string
value while expecting an integer.

## Supported Toolkits

* [ActiveRecord][ar]
* [M4DBI][m4dbi]
* [Sequel][sequel]
* [DataMapper][datamapper]

Besides these listed toolkits Ramaze should work with any other toolkit, these
however are the ones that have been confirmed to work just fine with Ramaze.

[sequel]: http://sequel.rubyforge.org/
[ar]: http://ar.rubyonrails.org/
[m4dbi]: https://github.com/Pistos/m4dbi
[datamapper]: http://datamapper.org/
