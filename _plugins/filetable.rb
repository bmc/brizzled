require 'yaml'

module Jekyll

  # Tag that reads from a YAML file, and generates a table, with embedded
  # Markdown.
  #
  # Usage: {% filetable file [options] %}
  #
  # The file must be in the _includes directory somewhere. The file is
  # assumed to have this format:
  #
  # -topic: name of topic   # for subheading
  #  items:                 # items in the topic, each of which has three fields
  #  - url: http://.../     # item's URL
  #    blurb: ...           # brief blurb, which will become the link text
  #    img: ...             # URL of image, for link text
  #    description: ...     # full description of item
  #
  # One of "blurb" or "img" is required. If both are present, "blurb" is used,
  # and "img" is ignored.
  #
  # Multiple topics are permitted, and multiple items within each topic.
  # Items and topics are written in the order they appear in the YAML.
  #
  # Embedded Markdown is permitted.
  #
  # Options are key=value pairs and may be:
  #
  # css_prefix:      Prefix for generated CSS tags. Default: file_table
  #                  Generated CSS tags are:
  #                    #{css_prefix}_table   - the <table> element
  #                    #{css_prefix}_heading - a heading row (<tr>)
  #                    #{css_prefix}_entry   - an entry row (<tr>)
  #                    #{css_prefix}_blurb   - a blurb cell (<td>)
  #                    #{css_prefix}_desc    - a description cell (<td>)
  class TableFromFile < Liquid::Tag

    # Must have file. Delimiter is option.

    SYNTAX = /^([^\s]+)\s*([\w=\w\s+]+)*/
    NAME = 'filetable'

    def initialize(tag_name, markup, tokens)
      super
      @name = TableFromFile::NAME
      markup = markup.strip
      @directive = "#{@name} #{markup}"
      if markup =~ SYNTAX
        @yaml = $1
        @options = {}
        if defined? $2
          $2.split.each do |opt|
            key, value = opt.split('=')
            if not value.nil?
              @options[key] = value
            end
          end
        end

        @css_prefix = @options.fetch('css_prefix', 'file_table')
        @table_css = "#{@css_prefix}_table"
        @subheading_css = "#{@css_prefix}_header"
        @entry_css = "#{@css_prefix}_entry"
        @blurb_css = "#{@css_prefix}_blurb"
        @desc_css = "#{@css_prefix}_desc"
      else
        raise SyntaxError.new("Syntax error in '#{@directive}': Must be " +
                              "#{name} yaml_file [options]")
      end
    end

    def render(context)
      dir = File.join(context.registers[:site].source, '_includes')
      yaml_file = File.join(dir, @yaml)
      if not File.exists?(yaml_file)
        error("Can't find file #{@yaml} in \\_includes directory.")
      end

      result = "<table markdown='1' class='#{@table_css}'>"

      data = YAML.load(File.open(yaml_file, 'r'))
      if not data.is_a? Array
        error("#{@yaml}: Expected sequence of sections.")
      end

      t = 0
      data.each do |section|
        t += 1
        topic = section['topic'] or
          error("Missing 'topic' in section #{t}")

        result += sub_heading(topic)

        items = section['items'] or
          error("Missing list items for topic '#{topic}'")
        if not items.is_a? Array
          error("Items for topic '#{topic}' is not a list")
        end

        i = 0
        items.each do |item|
          i += 1
          error_prefix = "Topic '#{topic}', item #{i}"
          url = item['url'] or error("#{error_prefix}: No URL")
          blurb = item['blurb']
          blurb_img = item['img']
          if not blurb.nil?
            # Use blurb
          elsif not blurb_img.nil?
            blurb = "![#{blurb_img}](#{blurb_img})"
          else
            error("#{error_prefix}: No 'blurb' or 'img'.")
          end
          desc = item['description'] or error("#{error_prefix}: No description")
          result += entry(blurb, url, desc)
        end
      end
      result += '</table>'
      return result
    end

    private

    def sub_heading(text)
      %{
  <tr class="#{@subheading_css}">
    <td align="center" colspan="2">#{text}</td>
  </tr>
}
    end

    def entry(blurb, link, desc)
      %{
  <tr class="#{@entry_css}">
    <td class="#{@blurb_css}">
      <a href="#{link}">#{blurb}</a>
    </td>
    <td class="#{@desc_css}">#{desc}</td>
  </tr>
}
    end
    def error(msg)
      raise FatalException.new("'#{@directive}': #{msg}")
    end
  end
end

Liquid::Template.register_tag(Jekyll::TableFromFile::NAME,
                              Jekyll::TableFromFile)
