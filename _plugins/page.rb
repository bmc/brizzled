require 'date'
require 'rubygems'
require 'maruku'

module Jekyll

  class Summary
    def initialize(file)
      @summary_file = file
    end

    def to_liquid()
      if File.exists?(@summary_file)
        Maruku.new(File.readlines(@summary_file).join("")).to_html
      else
        ""
      end
    end

    def inspect
      @summary_file
    end

    def to_s
      inspect
    end
  end

  class Page

    SUMMARY_FILE = "summary.md"

    @_tags = nil

    alias orig_init initialize
    def initialize(site, base, dir, name)
      orig_init(site, base, dir, name)
      @summary = Summary.new(File.join(@base, @dir, SUMMARY_FILE))
    end

    # Add some custom options to the Liquid data for the page.
    #
    # toc - set to "yes" if the "toc" variable is set, "no" if not.
    alias orig_to_liquid to_liquid
    def to_liquid
      h = orig_to_liquid
      h['toc'] = self.data['toc'] || 'no'
      h['disqus_id'] = self.data['disqus_id'] || nil
      h['disqus_developer'] = self.data['disqus_developer'] || nil
      h['date'] = self.date
      h['summary'] = @summary
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
