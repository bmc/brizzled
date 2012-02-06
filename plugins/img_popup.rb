# This plugin uses Mini Magick to generate a scaled down, inline image (really,
# it just uses Mini Magick to calculate the appropriate size; the real image is
# scaled by the browser), and then generates a popup with the full-size image,
# using jQuery UI Dialog. The printer-friendly view just uses the full-size
# image.
#
# This plugin is useful when you have to display an image that's too wide for
# the blog.
#
# USAGE:
#
#     imgpopup /relative/path/to/image nn% [title]
#
#     The image path is relative to "source". The second parameter is the scale
#     percentage. The third parameter is a title for the popup.
#
# CSS:
#
# To control what's shown on the screen versus what's shown when the article
# is printed, this plugin generates HTML with two classes: "screen" and "print".
# If your CSS rules use those classes appropriately, you can hide the printable
# view on the browser and vice versa.
#
# PREREQUISITES:
#
# To use this plugin, you'll need:
#
# - the mini_magick gem (in the Gemfile)
# - the Image Magick tool kit's mogrify(1) command installed on your system
#   and in the PATH
# - jQuery (in source/javascripts and in your head.html)
# - jQuery UI (in source/javascripts and in your head.html)
#
# EXAMPLE:
#
#     {% imgpopup /images/my-big-image.png 50% Check this out %}
#
#     You can see this plugin in use here:
#
#     http://brizzled.clapper.org/blog/2011/10/23/the-candidates/
#
# Copyright (c) 2012 Brian M. Clapper <bmc@clapper.org>
#
# Released under a standard BSD license.

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
