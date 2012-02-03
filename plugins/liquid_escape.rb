# Plugin to handle escaped Liquid tags (for when you want to put Liquid tags
# in your blog, but have them render verbatim).
#
# Copyright (c) 2011 Brian M. Clapper <bmc@clapper.org>
#
# Released under a standard BSD license.

module Jekyll

  class LiquidEscape < Liquid::Block

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

      content = lines_array.map do |line|
        line.gsub('{\\%', '{%').
             gsub('\\%}', '%}').
             gsub('\{\{', '{{').
             gsub('\}\}', '}}').
             gsub('&', '&amp;').
             gsub('<', '&lt;').
             gsub('>', '&gt;')
      end

      "<pre class='liquid-escape'>#{content.join("\n")}</pre>"
    end
  end
end

Liquid::Template.register_tag('showliquid', Jekyll::LiquidEscape)