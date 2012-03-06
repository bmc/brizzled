---
layout: post
title: "Using Twitter Bootstrap with Jekyll"
date: 2012-03-05 22:44
comments: true
categories: [jekyll, Twitter Bootstrap, ruby, css, javascript]
toc: true
---

# Introduction

I use [Jekyll][] to generate more than a few web sites. I like the separation
between the HTML presentation and the [Markdown][] content, and I like that
its easy to migrate Jekyll web sites to and from [GitHub Pages][].

Recently, I decided to update one of those web sites, partly to take it out
of the dark ages, and partly to learn more about [Twitter Bootstrap][]. Twitter
Bootstrap is a terrific package, consisting of Javascript, CSS and HTML that
is relatively easy to use, flexible, and customizable.

<!-- more -->

# Twitter Bootstrap

This article isn't about Twitter Bootstrap, though. If you want to know more
about this awesome package, here are some useful links:

* The original [Twitter Dev Blog announcement](https://dev.twitter.com/blog/bootstrap-twitter)
* The [Twitter Dev Blog entry on Twitter Bootstrap 2.0](https://dev.twitter.com/blog/say-hello-to-bootstrap-2)
* The [Twitter Bootstrap][] web site.
* Connor Turnbull's [Stepping Out with Bootstrap from Twitter](http://webdesign.tutsplus.com/tutorials/htmlcss-tutorials/stepping-out-with-bootstrap-from-twitter/)
* Ryan Bates' Railscast #328, [Twitter Bootstrap Basics](http://railscasts.com/episodes/328-twitter-bootstrap-basics), which is Rails-specific, but still provides a good introduction to Twitter Bootstrap.
* David Cochran's [Twitter Bootstrap 101: The Grid](http://webdesign.tutsplus.com/tutorials/complete-websites/twitter-bootstrap-101-the-grid/)

Once you're convinced of its awesomeness, you'll be ready to start using it.

# Integrating with Jekyll

There are, obviously, many ways to integrate Twitter Bootstrap with Jekyll.
In this article, I merely describe how _I_ did it.

## First, the easy way

While you're getting your feet wet, use the Twitter Bootstrap
[Customize and download][] page to build and customize a Bootstrap package.
From there, you can generate a zip file containing the Bootstrap images,
compiled CSS files, and bundled Javascript (including minified and unminified
versions).

To make it easy to update, unpack the resulting zip file in a `bootstrap`
directory, underneath your Jekyll source directory. Then, drop it into your
HTML layout(s). For instance:

{% codeblock Sample Jekyll Layout lang:html %}
<!DOCTYPE html>
<html>
<head>
  <meta http-equiv="content-type" content="text/html; charset=UTF-8"/>
  <title>reallycoolsoftware, Inc.</title>

  <!--[if lt IE 9]>
    <script src="http://html5shim.googlecode.com/svn/trunk/html5.js" type="text/javascript"></script>
  <![endif]-->

  <link rel="stylesheet" href="/lytebox/lytebox.css" type="text/css" media="screen"/>
  <link rel="shortcut icon" href="/favicon.ico"/>
  <link rel="stylesheet" type="text/css" href="/bootstrap/css/bootstrap.min.css"/>
  <link rel="stylesheet" type="text/css" href="/css/custom.css"/>

  <script type="text/javascript" src="/js/jquery.js"></script>
  <script src="http://ajax.googleapis.com/ajax/libs/jquery/1.7.1/jquery.min.js" type="text/javascript"></script>
  <script src="/bootstrap/js/bootstrap.min.js" type="text/javascript"></script>
  
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
</head>

<body>

  <div id="page">

   <!-- Twitter Bootstrap navbar -->

    <div class="navbar navbar-fixed-top">
      <div class="navbar-inner">
        <div class="container">
          <a class="btn btn-navbar" data-toggle="collapse" data-target=".nav-collapse">
            <span class="icon-bar"></span>
            <span class="icon-bar"></span>
            <span class="icon-bar"></span>
          </a>

          <a class="brand" href="/">Really Cool Software, LLC</a>
          <div class="nav-collapse">
            <ul class="nav">
              <li><a href="/index.html">Home</a></li>
              <li><a href="/who.html">Who We Are</a></li>
              <li><a href="/contact.html">Contact Us</a></li>
              <li><a href="/downloads.html">Downloads</a></li>
            </ul>
          </div>
        </div>
      </div>
    </div>

    <!-- Main content area -->

    <div class="container main-content-container">
      <div class="row">
        <div class="span2">
          <img id="logo" src="/images/logo.png">
        </div>

        <div class="span10 main-content">
          {{ content }}
        </div>
      </div>
    </div>

  </div>

</body>
</html>
{% endcodeblock %}

Then, regenerate your site via [Jekyll][]. When you generate your zip file
(above), be sure to include the [Collapse plugin][]. With that plugin in place,
and the following line in your template, your navbar will automatically collapse into a button when the screen size is too small--which is _much_
friendlier to mobile devices.

{% codeblock Sample Jekyll Layout -- Excerpt lang:html %}
<a class="btn btn-navbar" data-toggle="collapse" data-target=".nav-collapse">
  <span class="icon-bar"></span>
  <span class="icon-bar"></span>
  <span class="icon-bar"></span>
</a>
{% endcodeblock %}

## Going local

After awhile, you're going to get tired of going back out to the Twitter
Bootstrap site to generate a new zip file, every time you want to tweak your
site's look and feel. At that point, it's time to start building your own
Bootstrap bundle.

I chose a simple approach:

* Clone the [Twitter Bootstrap GitHub repo][] into a local directory
  outside my Jekyll source.
* Write some simple [Rake][] logic to copy the pieces I want, compiling the
  CSS, and minifying the Javascript in the process.

### Clone the repo

For the sake of this article, let's assume I cloned the 
[Twitter Bootstrap GitHub repo][] as follows:

{% codeblock Cloning the GitHub repo lang:bash %}
$ cd ~/src/open-source
$ git clone https://github.com/twitter/bootstrap.git
{% endcodeblock %}

I'm going to build my Rake logic with the assumption that the Bootstrap
code is in `~/src/open-source/bootstrap`. Keeping these files in a separate,
pristine directory means:

* I can easily share them among different Jekyll projects, and
* I can update the repository easily and cleanly.

### What Rake has to do

Rake is going to perform several tasks:

* If any of the Javascript files in the Bootstrap directory has changed,
  copy it to the local Jekyll `bootstrap` directory, minifying it with the
  Ruby [Uglifier][] gem.
* Generate a partial (in the Jekyll `_includes` directory) that contains
  `<script>` tags for all the Bootstrap Javascript files. Then, my layouts
  can simply include that file.
* Bootstrap's CSS files are actually written using the [LESS][] language.
  If any of the Bootstrap LESS files has changed, copy it to the local
  Jekyll directory.
* Compile all the LESS files (including a local `custom.less` that contains
  my CSS overrides) into one `bootstrap.min.css` file.

### Prerequisites

If you're using Jekyll, you already have a version of Ruby installed. But
you're going to need some additional software to accomplish the tasks
above.

First, install [node.js][] and the [Node Package Manager][] (npm). Once they're
in place, use npm to install the `less` package. I installed it in my home
directory:

{% codeblock Installing less lang:bash %}
$ cd
$ npm install less
$ ls node_modules/less/bin
lessc*
$ export PATH=$HOME/node_modules/.bin/lessc:$PATH  # add to .bashrc or .zshrc
{% endcodeblock %}

Next, install the [Uglifier][] gem and Rake (if you haven't already installed
Rake):

{% codeblock Installing Uglifier %}
$ gem install uglifier rake
Successfully installed uglifier-1.2.3
Fetching: rake-0.9.2.2.gem (100%)
Successfully installed rake-0.9.2.2
2 gems installed
Installing ri documentation for uglifier-1.2.3...
Installing ri documentation for rake-0.9.2.2...
Installing RDoc documentation for uglifier-1.2.3...
Installing RDoc documentation for rake-0.9.2.2...
{% endcodeblock %}

### The Rakefile

Now you're ready for the Rakefile.

#### Definitions and Utilities

First, let's put some simple definitions at the top of the Rakefile:

{% codeblock Rakefile constants lang:ruby %}
# Where our Bootstrap source is installed. Can be overridden by an environment variable.
BOOTSTRAP_SOURCE = ENV['BOOTSTRAP_SOURCE'] || File.expand_path("~/src/open-source/bootstrap")

# Where to find our custom LESS file.
BOOTSTRAP_CUSTOM_LESS = 'bootstrap/less/custom.less'
{% endcodeblock %}

Next, let's write a function to determine if two files are different. Rather
than just test the file modification times, let's also check the content, using
an MD5 digest.

{% codeblock Function to determine whether two files are different lang:ruby %}
def different?(path1, path2)
  require 'digest/md5'
  different = false
  if File.exist?(path1) && File.exist?(path2)
    path1_md5 = Digest::MD5.hexdigest(File.read path1)
    path2_md5 = Digest::MD5.hexdigest(File.read path2)
    (path2_md5 != path1_md5)
  else
    true
  end
end
{% endcodeblock %}

That function goes in the Rakefile. (I put it at the bottom, out of the way of
the tasks, but you can put it wherever you want.)

Let's also create a `bootstrap` task that invokes two subtasks, `bootstrap_css`
and `bootstrap_js`. That way, testing the Bootstrap Rake logic will be as
simple as typing `rake bootstrap`.

{% codeblock bootstrap task lang:ruby %}
task :bootstrap => [:bootstrap_js, :bootstrap_css]
{% endcodeblock %}

#### Copying the Javascript files

The `bootstrap_js` task, which copies the Bootstrap Javascript, files has to do
three things:

1. Detect which ones have changed.
2. Copy and minify them to our local Jekyll Bootstrap directory.
3. Generate the previously mentioned partial, in `_includes/bootstrap.js.html`

This task is straightforward enough:

{% codeblock Task to copy Bootstrap Javascript files lang:ruby %}
task :bootstrap_js do
  require 'uglifier'
  require 'erb'

  template = ERB.new %q{
  <!-- AUTOMATICALLY GENERATED. DO NOT EDIT. -->
  <% paths.each do |path| %>
  <script type="text/javascript" src="/bootstrap/js/<%= path %>"></script>
  <% end %>
  }

  paths = []
  minifier = Uglifier.new
  Dir.glob(File.join(BOOTSTRAP_SOURCE, 'js', '*.js')).each do |source|
    base = File.basename(source).sub(/^(.*)\.js$/, '\1.min.js')
    paths << base
    target = File.join('bootstrap/js', base)
    if different?(source, target)
      File.open(target, 'w') do |out|
        out.write minifier.compile(File.read(source))
      end
    end
  end

  File.open('_includes/bootstrap.js.html', 'w') do |f|
    f.write template.result(binding)
  end
end
{% endcodeblock %}

Note that I'm using ERB to generate the partial. You can do this inline,
of course, without ERB; I just find the ERB to be a little more readable.

#### Copying and compiling the LESS file

The `bootstrap_css` task, which copies the Bootstrap LESS files has three jobs:

1. Detect which ones have changed.
2. Copy them to our local Jekyll Bootstrap directory.
3. Compile them, along with our local `custom.less` file, into
   `bootstrap/css/bootstrap.min.css`.

First, let's take a look at the `custom.less` file:

{% codeblock custom.less lang:css %}
// ----------------------
// Stock Bootstrap stuff.
// ----------------------

@import "bootstrap.less";

// -----------------------
// Custom stuff goes here.
// -----------------------

// bootstrap.less doesn't include the responsive CSS. Pull it in.
@import "responsive.less";

// Customize the navbar color, and bump the font size up a bit.
@navbarBackground: #00445c;
@navbarBackgroundHighlight: #0087b8;
@navbarLinkColor: @white;
@navbarLinkColorHover: @grayLight;
@baseFontSize: 14px;
{% endcodeblock %}

`custom.less` pulls in `bootstrap.less`. `bootstrap.less` pulls in _nearly_
everything else we need. Thus, compiling `custom.less` is sufficient to get
everything else. I've also included some sample customizations, based on the
information at <http://twitter.github.com/bootstrap/less.html>.

If you don't want all the features normally bundled by `bootstrap.less`, you
can simply pull out the ones you want, put them into `custom.less`, and remove
the import of `bootstrap.less`.

Let's finish this section with the Rake task, `bootstrap_css`:

{% codeblock Task to copy and compile Bootstrap LESS files lang:ruby %}
task :bootstrap_css do |t|
  puts "Copying LESS files"
  Dir.glob(File.join(BOOTSTRAP_SOURCE, 'less', '*.less')).each do |source|
    target = File.join('bootstrap/less', File.basename(source))
    cp source, target if different?(source, target)
  end

  puts "Compiling #{BOOTSTRAP_CUSTOM_LESS}"
  sh 'lessc', '--compress', BOOTSTRAP_CUSTOM_LESS, 'bootstrap/css/bootstrap.min.css'
end
{% endcodeblock %}

#### Invoking Jekyll

We might as well have the Rakefile invoke Jekyll, while we're at it. Since
Jekyll is written in Ruby, we _could_ import Jekyll and invoke it that way,
but I'm doing it the lazy way, by invoking the `jekyll` command.

{% codeblock Jekyll task lang:ruby %}
task :default => :jekyll

task :jekyll => :bootstrap do
  sh 'jekyll'
end
{% endcodeblock %}

#### Changing the layout

The final change is to make our layouts include the `bootstrap.js.html` that's
generated by the `bootstrap_js` task. Simply change:

{% codeblock lang:html %}
<script src="/bootstrap/js/bootstrap.min.js" type="text/javascript"></script>
{% endcodeblock %}

to:

{% codeblock lang:django %}
{% raw %}
{% include bootstrap.js.html %}
{% endraw %}
{% endcodeblock %}

#### Running it

Now, we can build our Bootstrap-enabled site with one command:

{% codeblock Building the site lang:bash %}
$ rake
Copying LESS files
Compiling bootstrap/less/custom.less
lessc --compress bootstrap/less/custom.less bootstrap/css/bootstrap.min.css
jekyll
Configuration from /home/bmc/src/websites/reallycoolsoftware.com/_config.yml
Building site: /home/bmc/src/websites/reallycoolsoftware.com -> /home/bmc/src/websites/reallycoolsoftware.com/_site
Successfully generated site: /home/bmc/src/websites/reallycoolsoftware.com -> /home/bmc/src/websites/reallycoolsoftware.com/_site
{% endcodeblock %}

# Example

I used this approach on my corporate web site, [www.ardentex.com](http://www.ardentex.com/). My use of Twitter Bootstrap barely scratches the surface of what's available.

# Other approaches

* Jason Gritman has a [Jekyll-Bootstrap-Template][] that can help you get
  up and running.
* If you're blogging with Jekyll, check out [Jekyll Bootstrap][].

[Jekyll]: http://jekyllrb.com/
[Twitter Bootstrap]: http://twitter.github.com/bootstrap/
[Markdown]: http://daringfireball.net/projects/markdown/
[GitHub Pages]: http://pages.github.com/
[Customize and download]: http://twitter.github.com/bootstrap/download.html
[LESS]: http://lesscss.org/
[Collapse plugin]: http://twitter.github.com/bootstrap/javascript.html#collapse
[Twitter Bootstrap GitHub repo]: https://github.com/twitter/bootstrap/
[Rake]: http://rake.rubyforge.org/
[Uglifier]: https://github.com/lautis/uglifier
[node.js]: http://nodejs.org/
[Node Package Manager]: http://npmjs.org/
[Jekyll Bootstrap]: http://jekyllbootstrap.com/
[Jekyll-Bootstrap-Template]: https://github.com/jgritman/Jekyll-Bootstrap-Template
