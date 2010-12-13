module Jekyll

  class Articles < Liquid::Tag

    SYNTAX = /^([0-9]+)\s*([\w=\w\s+]+)*/
    NAME = 'articles'
    RENDER_TAGS = ['list', 'summary']

    def initialize(tag_name, markup, tokens)
      super
      @name = Articles::NAME
      markup = markup.strip
      @directive = "#{@name} #{markup}"
      if not markup =~ SYNTAX
        raise SyntaxError, "Syntax error in '#{@directive}': Must be " +
                           "#{name} max [options]"
      end

      @max = $1.to_i

      @options = {}
      if defined? $2
        $2.split.each do |opt|
          key, value = opt.split('=')
          if not value.nil?
            @options[key] = value
          end
        end

        @css_prefix = @options.fetch('css_prefix', 'recent')
        @table_css = "#{@css_prefix}_table"
        @subheading_css = "#{@css_prefix}_header"
        @entry_css = "#{@css_prefix}_entry"
        @blurb_css = "#{@css_prefix}_blurb"
        @desc_css = "#{@css_prefix}_desc"

      end
    end

    def render(context)
      pages = context.registers[:site].pages
      #pages = context.registers[:site].pages.sort {|p1, p2| p1.date <=> p2.date}
      "Let's try this: {{ page.name }}"
    end

    private
  end
end

Liquid::Template.register_tag(Jekyll::Articles::NAME,
                              Jekyll::Articles)
