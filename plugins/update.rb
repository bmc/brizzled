# Generate a div block, with class="update", allowing for embedded Markdown.
#
# Copyright (c) 2012 Brian M. Clapper <bmc@clapper.org>
#
# Released under a standard BSD license.

require 'rdiscount'

module Jekyll

  class Update < Liquid::Block

    def initialize(tag_name, markup, tokens)
      super
    end

    def render(context)
      # Superclass method will get the lines in the block. Older versions of
      # Jekyll returned an array of length 1. Newer versions seem to return
      # a string. This method handles either one.
      lines = super
      lines = lines[0] if lines.kind_of? Array
      lines_array = lines.split("\n").drop_while {|s| s.strip.length == 0}
      markdown = RDiscount.new(lines_array.join("\n"))
      "<div class='update'>#{markdown.to_html}</div>"
    end
  end
end

Liquid::Template.register_tag('update', Jekyll::Update)
