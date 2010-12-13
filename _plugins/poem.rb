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
      # Superclass method will get the lines in the block, as an array of
      # length 1.
      lines = super
      emit_lines(lines[0].split("\n"))
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
