module Jekyll

  class Poem < Liquid::Block

    def initialize(tag_name, markup, tokens)
      @author = markup.strip
      super
    end

    protected

    def render_all(nodelist, context)
      # See https://github.com/tobi/liquid/blob/master/lib/liquid/block.rb
      nodelist.collect do |token|
        begin
          if token.respond_to?(:render)
            s = token.render(context)
          else
            s = emit_lines token
          end
          s
        rescue Exception => e
          context.handle_error(e)
        end
      end
    end

    private

    def emit_lines(token)
      poem = ""
      # Break the token into individual input lines.
      token.each do |line|
        line.strip!
        if line.length > 0
          poem += (line + "<br/>")
        end
      end
      %{
<table border="0">
<tr valign="top">
<td class="poem-author">#{@author}</td>
<td class="poem-text">#{poem}</td>
</tr>
</table>
}
    end
  end
end

Liquid::Template.register_tag('poem', Jekyll::Poem)
