require 'date'

module Jekyll

  # Extensions to the Jekyll Page class.

  class Page

    BRIZZLED_URL = "http://brizzled.clapper.org"
    SUMMARY_FILE = "summary.md"
    SUMMARY_HTML = "summary.html"

    @_tags = nil

    alias orig_init initialize
    def initialize(site, base, dir, name)
      orig_init(site, base, dir, name)
      @summary = Summary.new(File.join(@base, @dir, SUMMARY_FILE),
                             File.join(@base, site.dest, @dir, SUMMARY_HTML))
    end

    # Add some custom options to the Liquid data for the page.
    #
    # toc - set to "yes" if the "toc" variable is set, "no" if not.
    alias orig_to_liquid to_liquid
    def to_liquid
      h = orig_to_liquid
      h['toc'] = self.data['toc'] || 'no'
      h['disqus_id'] = self.data['disqus_id'] || "#{BRIZZLED_URL}#{@dir}/"
      h['disqus_developer'] = self.data['disqus_developer'] || nil
      h['date'] = self.date
      h['summary'] = @summary
      h['has_summary'] = @summary.has_summary?
      h['path'] = File.join(@base, @dir, @name)
      h['now'] = Date.today
      h['tags'] = Tag.sort(tags)
      h
    end

    def tags
      (self.data['tags'] || "").split(',').map {|t| Tag.new(t)}
    end

    def full_url
      File.join(@dir, self.url)
    end

    def date
      self.data['date'] || Date.today
    end

    private

    def fix_tag
    end

  end

end
