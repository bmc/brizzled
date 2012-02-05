# Plugin to format something verbatim, without highlighting. Supports a title.
#
# Copyright (c) 2012 Brian M. Clapper <bmc@clapper.org>
#
# Released under a standard BSD license.

require './plugins/pygments_code'
require './plugins/code_figure'

module Jekyll

  class Verbatim < Liquid::Block
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
      lines = content.lines.drop_while do |s|
        s.strip.length == 0
      end.map do |s|
        escape_html(s)
      end.join("")

      figurize(tableize_code(lines), @title)
    end
  end
end

Liquid::Template.register_tag('verbatim', Jekyll::Verbatim)
