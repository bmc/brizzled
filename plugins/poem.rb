# Plugin to format a poem.
#
# Copyright (c) 2011 Brian M. Clapper <bmc@clapper.org>
#
# Released under a standard BSD license.

module Jekyll

  class Poem < Liquid::Block

    def initialize(tag_name, markup, tokens)
      @author = markup.strip
      if @author.length == 0
        @author = nil
      end
      super
    end

    def render(context)
      # Superclass method will get the lines in the block. Older versions of
      # Jekyll returned an array of length 1. Newer versions seem to return
      # a string. This method handles either one.
      lines = super
      lines = lines[0] if lines.kind_of? Array
      lines_array = lines.split("\n").drop_while {|s| s.strip.length == 0}
      emit_lines(lines_array)
    end

    private

    def emit_lines(token)
      poem = ""
      # Break the token into individual input lines.
      token.each do |line|
        line.strip!
        poem << (line + "<br/>")
      end

      html = %{
<table border="0" class="poem">
<tr valign="top">
}

      if @author
        html << "<td class='poem-author'>#{@author}</td>"
      end

      html << %{
<td class="poem-text">#{poem}</td>
</tr>
</table>
}
      html
    end
  end
end

Liquid::Template.register_tag('poem', Jekyll::Poem)
