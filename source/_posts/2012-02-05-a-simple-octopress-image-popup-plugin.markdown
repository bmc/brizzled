---
layout: post
title: "A Simple Octopress Image Popup Plugin"
date: 2012-02-05 19:44
comments: true
categories: [blogging, jekyll, octopress, javascript, css, ruby]
toc: true
---

# Introduction

[Octopress][] does a good job of generating a blog that scales nicely for large
computer screens _and_ smaller devices (such as my iPad). However, it's
possible to thwart Octopress's best intentions, as I inadvertently managed to
do.

I occasionally post [cartoons](http://brizzled.clapper.org/blog/tags/cartoons/)
to my blog, and the images tend to be large enough that they flow outside the
boundaries of the blog's text area, which looks like crap. My first attempt
at solving the problem was to use CSS to set a minimum size for the text
region. That solution, however, ruins the blog layout for _smaller_ devices,
such as a tablet.

There's a straightforward solution to this problem, though.

The general idea is to display a smaller version of the image in the text
area; when a reader clicks on that image (or taps it, on the iPad), the
full size image appears in a [modal popup][]. Many sites use this approach,
of course, including Facebook and Google+. Its popularity is part of its
appeal.

This solution can be implemented in a simple plugin, making it easy to drop
into individual blog articles.

<!-- more -->

# Prerequisites

Since I am already using [jQuery][] and [jQuery UI][] elsewhere in my blog,
I elected to use them to solve this problem, as well. Here's the full set
of extra software necessary to write the plugin:

* jQuery UI: I use [jQuery UI Dialog][] to generate the popup containing
  the full size image.
* jQuery: Necessary for jQuery UI.
* The [mini_magick][] Ruby Gem, used to query the image file to get its
  size. The plugin _could_ use mini_magick to scale the image down,
  but it's just as easy to let the browser do the scaling.
* Either [ImageMagick][] or [GraphicsMagick][], because mini_magick uses
  the *mogrify*(1) command to do its work.
* [Erubis][], for fast [ERB][] template processing. (You can just use ERB,
  itself, if you want.)

I _could_ have used the [RMagick][] gem, instead of mini_magick and
*mogrify*(1), but RMagick uses a _lot_ of memory on my machine.

# The Plugin

## Usage

The plugin implements a [Liquid][] template tag. The tag syntax is
straighforward:

{% codeblock %}
{% raw %}
{% imgpopup /path/to/image percent% [title] %}
{% endraw %}
{% endcodeblock %}

The image path is relative to the `source` directory. The percent argument is
the amount to scale the image down for the clickable preview. The optional
title is put in the title bar of the modal popup. Here's a real example:

{% codeblock %}
{% raw %}
{% imgpopup /images/bigimage.png 50% My Big Image %}
{% endraw %}
{% endcodeblock %}

## Implementation

The plugin, itself, is not large at all. It consists three distinct parts:

* An ERB template for the HTML and Javascript that will be emitted.
* The initializer, which parses the arguments given to the tag.
* The `render` method, which actually generates the HTML and Javascript.

### The Plugin Code

Two files comprise the plugin: The Ruby source code and an accompanying ERB
template.

Here's the Ruby code, which belongs in the `plugins` directory. It's also
available in my GitHub repository, at
<https://github.com/bmc/brizzled/blob/master/plugins/img_popup.rb>.

{% codeblock img_popup.rb lang:ruby %}
require 'mini_magick'
require 'rubygems'
require 'erubis'
require './plugins/raw'

module Jekyll

  class ImgPopup < Liquid::Tag
    include TemplateWrapper

    @@id = 0

    TEMPLATE_NAME = 'img_popup.html.erb'

    def initialize(tag_name, markup, tokens)
      args = markup.strip.split(/\s+/, 3)
      raise "Usage: imgpopup path nn% [title]" unless [2, 3].include? args.length

      @path = args[0]
      if args[1] =~ /^(\d+)%$/
        @percent = $1
      else
        raise "Percent #{args[1]} is not of the form 'nn%'"
      end

      template_file = Pathname.new(__FILE__).dirname + TEMPLATE_NAME
      @template = Erubis::Eruby.new(File.open(template_file).read)
      @title = args[2]
      super
    end

    def render(context)
      source = Pathname.new(context.registers[:site].source).expand_path

      # Calculate the full path to the source image.
      image_path = source + @path.sub(%r{^/}, '')

      @@id += 1
      vars = {
        'id'      => @@id.to_s,
        'image'   => @path,
        'title'   => @title
      } 

      # Open the source image, and scale it accordingly.
      image = MiniMagick::Image.open(image_path)
      vars['full_width'] = image[:width]
      vars['full_height'] = image[:height]
      image.resize "#{@percent}%"
      vars['scaled_width'] = image[:width]
      vars['scaled_height'] = image[:height]

      safe_wrap(@template.result(vars))
    end
  end
end

Liquid::Template.register_tag('imgpopup', Jekyll::ImgPopup)
{% endcodeblock %}

Here's the ERB template, stored in file `img_popup.html.erb`, also in the
`plugins` directory. The template could, of course, be _in_ the Ruby file, but
I put it in a separate file, because I find it easier to maintain that way.

{% codeblock img_popup.html.erb lang:html %}
{% raw %}
<div class="imgpopup screen">
  <div class="caption">Click the image for a larger view.</div>
  <a href='javascript:void(0)' style="text-decoration: none" id="image-<%= id %>">
    <img src="<%= image %>"
         width="<%= scaled_width %>" height="<%= scaled_height %>"
         alt="Click me."/>
  </a>
  <div id="image-dialog-<%= id %>" style="display:none">
    <img src="<%= image %>"
         width="<%= full_width %>" height="<%= full_height %>"/>
    <br clear="all"/>
  </div>
</div>
<script type="text/javascript">
  jQuery(document).ready(function() {
    jQuery("#image-dialog-<%= id %>").hide();
    jQuery("#image-dialog-<%= id %>").dialog({
      autoOpen:  false,
      modal:     true,
      draggable: false,
      minWidth:  <%= full_width + 40 %>,
      minHeight: <%= full_height + 40 %>,
      <% if title -%>
      title:     "<%= title %>",
      <% end -%>
      show:      'scale',
      hide:      'scale'
    });

    jQuery("#image-<%= id %>").click(function() {
      jQuery("#image-dialog-<%= id %>").dialog('open');
    });

  });
</script>
<div class="illustration print">
  <img src="<%= image %>" width="<%= full_width %>" height="<%= full_height %>"/>
</div>
{% endraw %}
{% endcodeblock %}

#### A Quick Walkthrough

##### The ERB Template

The ERB template is fairly straightforward.

The template generates HTML that does several things. The initial `<div>`
displays the scaled-down version of the image. The scaled width and height are
passed to the template renderer, but the image is the full size image; the
browser will do the actual scaling. The image is surrounded by an anchor tag,
as a trivial means to make it clickable. That initial `<div>` also
contains the hidden `<div>` will be displayed in the popup. Note the
`screen` class: This class is used by the CSS rules to suppress display of the
entire `<div>` when the media type is `print`.

Next is a `<script>` tag containing the jQuery logic that sets up the
dialog and registers the click event that triggers the dialog's display. For
details on the jQuery UI Dialog capability, see the [jQuery UI Dialog][] web
page.

Finally, there's one last `<div>`, which the CSS rules ensure is the
one that's displayed in `print` mode.

##### The Ruby Part

The plugin's logic consists of just two methods. The initializer is simple:

* It parses and validates the arguments to the tag, as passed in the `markup`
  parameter.
* It instantiates an `Erubis::Eruby` instance on the ERB template, storing
  the `Eruby` object in an instance variable.

The renderer is also fairly straightforward:

* It calculates the location of the `source` directory and figures out where
  the image is underneath that directory.
* It creates a new, unique ID, to be used for the generated HTML. This allows
  the plugin to generate multiple dialogs in one page, without causing
  problems.
* It gets the image's width and height, and calculates the scaled width and
  height.
* It generates the resulting HTML, wrapping it with `safe_wrap` so that
  Jekyll doesn't attempt to parse and transform it.

### jQuery

Be sure to add the following two lines to `source/_includes/custom.head.html`,
to make jQuery and jQuery UI available:

{% codeblock lang:html %}
{% raw %}
<script src="http://ajax.googleapis.com/ajax/libs/jquery/1.7.1/jquery.min.js" type="text/javascript"></script>
<script src="https://ajax.googleapis.com/ajax/libs/jqueryui/1.8.16/jquery-ui.min.js" type="text/javascript"></script>
{% endraw %}
{% endcodeblock %}

### The CSS

The only thing missing is the CSS. In my Sass rules for the screen, I added
these rules:

{% codeblock lang:sass %}
.caption {
    font-style: italic;
    font-size: 80% !important;
    text-align: center;
    @include centered(100%);
}

div.imgpopup {
    border: 1px solid #cccccc;
    @include rounded-border(10px);
    margin: 10px;
    @include centered(80%);
    text-align: center;

    .caption {
        margin: 0 !important;
    }
}

.screen {
    display: none;
}
{% endcodeblock %}

For the printer-friendly Sass rules, I use:

{% codeblock lang:sass %}
.screen {
    display: none;
}

.illustration {
    @include centered(100%);
}
{% endcodeblock %}

# Wrap-up

For some examples of this plugin in actual use, see these two blog articles:

* [The Candidates](http://brizzled.clapper.org/blog/2011/10/23/the-candidates/)
* [The Candidates, Part 2](http://brizzled.clapper.org/blog/2011/10/25/the-candidates-part-2/)

The actual, running code is located in this blog's GitHub repo, here:

<https://github.com/bmc/brizzled/blob/master/plugins/img_popup.rb>. 

Feel free to use the code, adapt it to your needs, or send me suggestions. It's
released under a [BSD License](http://opensource.org/licenses/BSD-3-Clause).

[Jekyll]: http://jekyllrb.com/
[Octopress]: http://octopress.org/
[Liquid]: https://github.com/Shopify/liquid
[jQuery]: http://jquery.org
[jQuery UI]: http://jqueryui.com/
[jQuery UI Dialog]: http://jqueryui.com/demos/dialog/
[modal popup]: http://en.wikipedia.org/wiki/Modal_window
[Erubis]: http://www.kuwata-lab.com/erubis/
[ERB]: http://ruby-doc.org/stdlib-1.9.3/libdoc/erb/rdoc/ERB.html
[mini_magick]: https://github.com/probablycorey/mini_magick
[RMagick]: http://rmagick.rubyforge.org/
[ImageMagick]: http://www.imagemagick.org/
[GraphicsMagick]: http://www.graphicsmagick.org/