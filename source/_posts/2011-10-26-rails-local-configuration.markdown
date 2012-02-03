---
layout: post
comments: true
title: "Rails Local Configuration"
date: 2011-10-26 00:00
categories: [ruby, rails, programming]
---

# The problem

I needed to fire up the [Rails][] 3 server to listen on a port other than the
default port 3000. Obviously, I could simply run it like this:

    rails server -p 1234

However, for simplicity (and so I wouldn't forget), I wanted to be able to
*configure* the alternate port. It seems that the easiest way to accomplish
that goal is by metaprogramming `Rails::Server` in `config/boot.rb`, as
described in this
[StackOverflow answer](http://stackoverflow.com/questions/3842818#6539193).

However, I didn't want to hack the port for *everyone*; I wanted a solution
that would be specific to a `RAILS_ENV` setting.

# A simple solution

The simplest solution (to me) was to provide for a `config/config-local.yml`
file, keyed to each environment. For instance, to allow me to use port 1234
when `RAILS_ENV` is set to `bmc`, I'd simply put the following in that file:

    # Local configuration.
    #
    # NOTE: This file is NOT supplied by Rails. See the logic at the bottom
    # of boot.rb.
    #
    # port - TCP port on which to run the Rails server. Default: 3000
    # -----------------------------------------------------------------------

    bmc:
      port: 1234

It's a simple matter to provide the necessary logic in `config/boot.rb`:

{% gist 1321419 %}

Note that the code is more general-purpose than merely what's necessary to 
handle a TCP port override.

* The `OPTIONS` hash defines the default values for various configuration
  parameters.
* The `fix_config_hash` function recursively walks through a hash table,
  converting its string keys to Ruby symbols. It's used to convert the
  parsed YAML file into a hash that can be merged with `OPTIONS`.
* The final merged configuration is stored in a `LocalConfig` global constant,
  which is accessible elsewhere in the Rails application.
* The configuration YAML file is preparsed with [ERB][], allowing ERB
  template logic in the YAML configurations.

[ERB]: http://www.ruby-doc.org/stdlib-1.9.2/libdoc/erb/rdoc/ERB.html

# Sample runs

When I use the `development` environment, Rails listens on the standard port:

    $ RAILS_ENV=development rails server
    Loading local configuration file /home/bmc/src/rails-test/config/config-local.yml
    => Booting Mongrel
    => Rails 3.1.0 application starting in development on http://0.0.0.0:3000
    => Call with -d to detach
    => Ctrl-C to shutdown server
    ^C
    $

When I use the `bmc` environment, Rails listens on port 1234:

    $ RAILS_ENV=bmc rails s
    Loading local configuration file /home/bmc/src/rails-test/config/config-local.yml
    => Booting Mongrel
    => Rails 3.1.0 application starting in development on http://0.0.0.0:1234
    => Call with -d to detach
    => Ctrl-C to shutdown server
    ^C
    $

[Rails]: http://www.rubyonrails.org/
