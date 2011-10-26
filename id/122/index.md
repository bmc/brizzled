---
layout: article
title: 'Rails Local Configuration'
tags: ruby, rails
date: 2011-10-26
toc: toc
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
    # Each section's key is the name of a Rails environment. Currently
    # supported values:
    #
    # port - TCP port on which to run the Rails server. Default: 3000
    # -----------------------------------------------------------------------

    bmc:
      port: 1234

It's a simple matter to provide the necessary logic in `config/boot.rb`:

<script src="https://gist.github.com/1316837.js"> </script>

# Sample runs

When I use the `development` environment, Rails listens on the standard port:

    $ RAILS_ENV=development rails server
    Loading local configuration file /home/bmc/src/rails-test/config/config-local.yml
    => Booting Mongrel
    => Rails 3.1.0 application starting in development on http://0.0.0.0:3000
    => Call with -d to detach
    => Ctrl-C to shutdown server
    ^C

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
