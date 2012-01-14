require 'rubygems'
require 'fileutils'
require File.join(File.dirname(__FILE__), 'blog_util.rb')

module Jekyll

  # Deferred generator
  class FeedContent

    include Jekyll::BlogUtil

    def initialize(site, page)
      @html_file = page.html_file
      @page_url  = page.full_url
      @site      = site
      @page      = page
      @content   = nil
    end

    def to_liquid
      unless @content
        unless File.exists? @html_file
          @page.render(@site.layouts, @site.site_payload)
        end

        @content = generate_feed_content(@page.content)
      end

      @content
    end

    def to_s
      "#{self.class.name}<#{@html_file}>"
    end

    def inspect
      self.to_s
    end

    def generate_feed_content(raw_content)
      prefix = <<END_PREFIX
**Note: If you're reading this article directly from the RSS or ATOM feed,
you're _not_ seeing it as the author intended it to be seen. Please visit the
[actual article](#{@page_url}) for the full experience.**

END_PREFIX

      make_html(prefix + raw_content)
    end
  end
end
