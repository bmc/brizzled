# Plugin to handle escaped Liquid tags (for when you want to put Liquid tags
# in your blog, but have them render verbatim).
#
# Copyright (c) 2011 Brian M. Clapper <bmc@clapper.org>
#
# Released under a standard BSD license.

require './plugins/pygments_code'
require './plugins/code_figure'

module Jekyll

  class LiquidEscape < Liquid::Block
    include HighlightCode
    include CodeFigure

    def initialize(tag_name, markup, tokens)
      @title = markup.strip
      @title = nil if @title.length == 0
      super
    end

    def render(context)
      # Superclass method will get the lines in the block. Older versions of
      # Jekyll returned an array of length 1. Newer versions seem to return
      # a string. This method handles either one.
      content = super
      content = content[0] if content.kind_of? Array
      lines_array = content.lines.drop_while {|s| s.strip.length == 0}

      content = lines_array.map do |line|
        escape_html(line.gsub('{\\%', '{%').
                         gsub('\\%}', '%}').
                         gsub('\{\{', '{{').
                         gsub('\}\}', '}}'))
      end

      figurize(tableize_code(content.join("")), @title)
    end
  end
end

Liquid::Template.register_tag('showliquid', Jekyll::LiquidEscape)