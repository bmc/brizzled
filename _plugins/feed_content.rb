require 'rubygems'
require 'maruku'
require 'fileutils'

module Jekyll

  # Deferred generator
  class FeedContent
    def initialize(page_url, html_file)
      @html_file = html_file
      @page_url = page_url
      @content = nil
    end

    def to_liquid
      @content ||= generate_feed_content File.readlines(@html_file).join("")
    end

    def to_s
      "#{self.class.name}<#{@html_file}>"
    end

    def inspect
      self.to_s
    end

    def generate_feed_content(html)
      prefix = [
        "<ap><b><i>Note: If you're reading this article directly from the",
        "RSS or ATOM feed, you're not seeing it as the author intended it to",
        "be seen. Please visit <a href='#{@page_url}'>#{@page_url}</a>",
        "for the full experience.</i></b></p>" 
      ]

      # Remove the leading content, up to just before the "articles-container"
      # <div>, and after the close of the <div> (which is marked).

      content = html.split("\n").drop_while do |line|
        # This will keep <body>, so the drop(1) that follows will have to
        # get rid of it.
        line !~ /^\s*<!-- #START ARTICLE/
      end.drop(1).take_while do |line|
        line !~ /^\s*<!-- #END ARTICLE/
      end.map do |line|
        line.strip
      end.select do |line|
        ! (line.empty? || line.include?('printer-friendly.html'))
      end
      (prefix + content).join("\n")
    end
  end
end
