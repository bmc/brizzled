require 'date'
require 'rubygems'
require 'maruku'
require 'fileutils'

module Jekyll

  class Summary
    def initialize(source_file, html_file)
      @summary_file = source_file
      @summary_html = html_file
    end

    def to_liquid
      File.exists?(@summary_file) ? get_html : ""
    end

    def has_summary?
      File.exists?(@summary_file)
    end

    def inspect
      @summary_file
    end

    def to_s
      inspect
    end

    def get_html
      make = false
      if not File.exists?(@summary_html)
        puts("#{@summary_html} does not exist. Making it.")
        make = true
      elsif (File.mtime(@summary_html) <=> File.mtime(@summary_file)) < 0
        puts("#{@summary_html} is older than #{@summary_file}. Remaking it.")
        make = true
      end

      if make
        html = Maruku.new(File.readlines(@summary_file).join("")).to_html
        FileUtils.mkdir_p(File.dirname(@summary_html))
        f = File.open(@summary_html, 'w')
        f.write(html)
        f.close
      else
        html = File.readlines(@summary_html).join("")
      end

      html
    end
  end

  class Page

    SUMMARY_FILE = "summary.md"
    SUMMARY_HTML = "summary.html"

    @_tags = nil

    alias orig_init initialize
    def initialize(site, base, dir, name)
      orig_init(site, base, dir, name)
      @summary = Summary.new(File.join(@base, @dir, SUMMARY_FILE),
                             File.join(@base, "_site", @dir, SUMMARY_HTML))
    end

    # Add some custom options to the Liquid data for the page.
    #
    # toc - set to "yes" if the "toc" variable is set, "no" if not.
    alias orig_to_liquid to_liquid
    def to_liquid
      h = orig_to_liquid
      h['toc'] = self.data['toc'] || 'no'
      h['disqus_id'] = self.data['disqus_id'] || "http://brizzled.clapper.org#{@dir}/"
      h['disqus_developer'] = self.data['disqus_developer'] || nil
      h['date'] = self.date
      h['summary'] = @summary
      h['has_summary'] = @summary.has_summary?
      h['now'] = Date.today
      h
    end

    def full_url
      File.join(@dir, self.url)
    end

    def date
      self.data['date'] || Date.today
    end

  end

end
