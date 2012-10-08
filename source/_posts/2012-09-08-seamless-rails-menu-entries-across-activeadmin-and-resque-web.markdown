---
layout: post
title: "Seamless Rails menu entries across ActiveAdmin and Resque Web"
date: 2012-09-08 00:06
comments: true
categories: [rails, ruby, activeadmin, programming]
toc: true
---

# Introduction

For one of my clients, I built a customer web portal in [Rails][], and I
used the [ActiveAdmin][] gem to provide a slick administrative interface.
The site also uses [Resque][] to process background jobs, and the Resque
web interface is mounted within the Rails application.

With these components in place, I wanted to provide cross-linking navigation
menu ("navbar") items within the application itself, within ActiveAdmin, and
within the Resque web engine.

The application navbar is easy, of course, since it's entirely under my
control. Adding links to Resque web and ActiveAdmin navbars is more
challenging.

Here's how I did it.

<!-- more -->

# Hacking Resque Web

I wanted the Resque Web navbar to contain two additional links:

* "Live Site" links back to the application.
* "Admin" links to the ActiveAdmin interface.

Adding these links turns out to be ugly, but workable. First, I added a file
called `lib/resque_additions.rb`, containing the following code. This code
augments the existing Resque Sinatra application to include two new routes.

This is a _complete_ hack.

I need to augment it to use the Rails helpers, to decouple it from
the Rails `routes.rb` file. I haven't yet taken the time to figure out how
to do that properly.

{% codeblock lib/resque_additions.rb lang:ruby %}
{% raw %}
require 'resque/server'

# Poked into the Resque web interface, to provide some additional tabs:
#
# Admin - routes back to the main admin page
# Site  - goes to the main site.
#
# WARNING: This stuff is coupled to the routes.rb file, to a degree.
module ResqueAdditions
  module Server

    def self.included(base)
      base.class_eval {

        # This route *really* corresponds to "<resque-mount-point>/admin".
        # We're just going to redirect to "/admin".
        get '/admin' do
          redirect "/admin"
        end

        get "/live site" do
          redirect "/"
        end
      }
    end
  end
end

# Add the tabs. Resque-web downcases the tab name and generates the route URL
# from that.
Resque::Server.tabs << 'Admin'
Resque::Server.tabs << 'Live Site'

# Monkeypatch the Resque::Server (Resque web) class, forcing it to include our
# module, above.
Resque::Server.class_eval do
  include ResqueAdditions::Server
end
{% endraw %}
{% endcodeblock %}

Next, I simply `require` that file in the `config/application.rb` source,
and the Resque web interface is automatically augmented when Rails starts.

# Customizing ActiveAdmin

By default, ActiveAdmin provides a "Live Site" navbar link that points back to
the main application. I needed a "Jobs" link to point to the Resque web
interface.

I'm using ActiveAdmin 0.5.0, which has support for extending or overriding the
menu, utility menu, header and footer. Adding the "Jobs" link to the header
menu in ActiveAdmin is relatively simple, once you figure out how. The "figure
out how" part required some spelunking through the ActiveAdmin source, because
this new feature is not especially well-documented yet.

Here's what I came up with. Someone more knowledgeable is welcome to correct
me on the finer points.

First, in your `routes.rb` file, modify the line where you mount the Resque
web application, so that it defines a URL helper path:

{% codeblock Change to routes.rb lang:ruby %}
{% raw %}
scope constraints: is_administrator do
  # WARNING: If you change where this is mounted, you may have to edit
  # lib/resque_additions.rb, as well.
  mount Resque::Server, :at => '/admin/jobs', as: :admin_jobs
end
{% endraw %}
{% endcodeblock %}

Next, we're going to make two changes to `config/initializers/active_admin.rb`.
The first change is to add the following class to the top of the file:

{% codeblock Custom ActiveAdmin header menu lang:ruby %}
{% raw %}
# Customize the ActiveAdmin header to add our own item. NOTE: This class
# must be registered as the view factory for the header. See below, in the
# setup block.
class MyAdminHeader < ActiveAdmin::Views::Header
  include Rails.application.routes.url_helpers

  def build(namespace, menu)
    # Create a new menu item and add it to the menu. By default, all menu
    # items have priority 10, and they're sorted within the priority. Setting
    # this item's priority to 11 ensures that it appears after the other
    # menu items (except for "Live Site"), which is what we want.
    #
    # See lib/active_admin/dashboards.rb in the activeadmin gem, for
    # example.
    unless menu['jobs']
      new_item = ActiveAdmin::MenuItem.new(id: 'jobs',
                                           label: 'Jobs',
                                           url: admin_jobs_path,
                                           priority: 11)
      menu.add new_item
    end

    # Now, invoke the parent class's build method to put it all together.
    super(namespace, menu)
  end
end
{% endraw %}
{% endcodeblock %}

Next, wire it into ActiveAdmin within the `setup` block, as shown below:
{% codeblock Change to routes.rb lang:ruby %}
{% raw %}

ActiveAdmin.setup do |config|

  # Other settings are here
  # ...

  config.view_factory.header = MyAdminHeader
end
{% endraw %}
{% endcodeblock %}

# Voilà!

Now, when you fire up Rails, you should have "Live Site" and "Admin" links
within the Resque web interface's navigation menu ("navbar"), and you should
have an additional "Jobs" link within the ActiveAdmin navigation menu
("navbar").

Your mileage may vary, but this worked for me.

[Rails]: http://rubyonrails.org/
[ActiveAdmin]: http://activeadmin.info/
[Resque]: https://github.com/defunkt/resque